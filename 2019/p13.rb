#!/usr/bin/env ruby
# coding: utf-8

require_relative 'intcode'
require 'json'
require 'pry'

class ArcadeMachine
  attr_accessor :game

  def initialize(program)
    @program = program
    @input = IO.pipe
    @output = IO.pipe
    @game = IntcodeMachine.new(@program, @input[0], @output[1], nil)
    @thread = nil
  end

  def run
    @thread = Thread.new { @game.run }
    @thread.join
  end

  def input
    @input[1]
  end
  
  def output
    @output[0]
  end
end

# hack String class for colored text
# https://stackoverflow.com/questions/1489183/colorized-ruby-output
class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end
end
###

class ScreenReader
  TILE_TYPES = {
    0 => :EMPTY,
    1 => :WALL,
    2 => :BLOCK,
    3 => :PADDLE,
    4 => :BALL
  }.freeze

  SPRITES = {
    EMPTY: "⬛",
    WALL: "⬜",
    BLOCK: "❎",
    PADDLE: "🏓",
    BALL: "🎾"
  }

  attr_accessor :screen

  def initialize(machine, output=$stdout)
    @commands = machine.output
    @screen = Hash.new(0)
    @output = output
    @score = 0
  end

  def process
    # keep track of the state of things by reading all the input, and
    # go all the way to the end.
    commands = @commands.readlines(chomp: true).each_slice(3)
    commands.each do |x, y, tile|
      screen_write(x.to_i, y.to_i, tile.to_i)
    end
  end

  def run
    loop do
      command = []
      3.times do
        sub = @commands.gets
        return if sub.nil?
        command << sub.chomp.to_i
      end
      screen_write(*command)
    end
  end

  def num_blocks
    @screen.count { |k, v| TILE_TYPES[v] == :BLOCK }
  end

  def paint_display
    clear_screen
    paint_score
    (0..20).each do |y|
      line = ""
      (0..35).each do |x|
        line << render(x, y)
      end
      send_line(line)
    end
  end

  def render(x, y)
    tile = TILE_TYPES[@screen[[x,y]]]
    SPRITES[tile]
  end

  def paint_score
    # output single line of score using colorize hack above
    @output.puts "SCORE: #{@score.to_s.rjust(10, ' ')}".red
  end

  def clear_screen
    @output.puts "\e[H\e[2J"
  end

  def send_line(line)
    @output.puts line
  end

  private

  def screen_write(x, y, tile)
    if x == -1 && y == 0
      @score = tile
    end
    @screen[[x,y]] = tile
    # $stderr.puts "(#{x}, #{y}) = #{TILE_TYPES[tile].to_s}"
  end
end

class ArcadeCabinet
  # has a screen and a machine inside
  # has a joystick that takes inputs and feeds them to the machine
  # screen will draw when the machine gives commands
  class JOY_DIR
    RIGHT = 1
    LEFT = -1
    CENTER = 0
  end

  def initialize(program)
    @program = program
    @machine = ArcadeMachine.new(@program)
    @screen = ScreenReader.new(@machine)  # screen reads machine.output
    @joystick_io = @machine.input
    @threads = []
  end

  require 'io/console'

  # https://gist.github.com/acook/4190379
  # Reads keypresses from the user including 2 and 3 escape character sequences.
  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  def decode_char(ch)
    case ch
    when "\e[A"
      return :UP_ARROW
    when "\e[B"
      return :DOWN_ARROW
    when "\e[C"
      return :RIGHT_ARROW
    when "\e[D"
      return :LEFT_ARROW
    when "\u0003"
      return :CONTROL_C
    when "\n"
      return :ENTER
    when "s"
      return :s
    when "o"
      return :o
    when "r"
      return :r
    when "p"
      return :p
    else
      return :OTHER
    end
  end

  def run
    # machine watches for joystick and writes to screen
    @threads << Thread.new { @machine.run }
    # screen continually reads from machine into buffer
    @threads << Thread.new { @screen.run }
    loop do
      # get input and feed it to the machine
      key_press = decode_char(read_char)
      break if key_press == :CONTROL_C
      process_key!(key_press)
      sleep(0.1)
      @screen.paint_display
    end
  end

  def process_key!(key)
    case key
    when :RIGHT_ARROW
      @joystick_io.puts JOY_DIR::RIGHT
    when :LEFT_ARROW
      @joystick_io.puts JOY_DIR::LEFT
    when :UP_ARROW
      @joystick_io.puts JOY_DIR::CENTER
    when :DOWN_ARROW
      @joystick_io.puts JOY_DIR::CENTER
    when :ENTER
      @joystick_io.puts JOY_DIR::CENTER
    when :s
      save
    when :o
      save
    when :r
      reload_last
    end
  end

  def save
    # gather the memory state from the intcode machine, and the current screen contents
    # and dump them to a file in the "savefiles" directory.
    filename = "savefiles/p13_#{Time.now.strftime('%Y%m%d_%H%M%S')}.save"
    file = File.new(filename, "w")
    file.puts @machine.game.program*','
    gamestate = {
      ip: @machine.game.ip,
      relative_base: @machine.game.relative_base
    }
    file.puts gamestate.to_json
    screenstate = {
      screen_data: @screen.screen.to_a
    }
    file.puts screenstate.to_json
    file.close
  end

  def reload(filename)
    file = File.open(filename).readlines(chomp: true)
    @machine.game.program = file[0].split(',').map(&:to_i)
    gamestate = JSON.parse(file[1])
    @machine.game.ip = gamestate['ip']
    @machine.game.relative_base = gamestate['relative_base']
    screenstate = JSON.parse(file[2])
    @screen.screen = screenstate['screen_data'].to_h
  end

  def reload_last
    filename = find_last_save
    reload(filename)
    @screen.paint_display
  end

  def find_last_save
    Dir.glob("savefiles/p13*.save").max_by {|f| File.mtime(f) }
  end
end

if __FILE__ == $0
  program = DATA.readlines(chomp: true)[0].freeze
  machine = ArcadeMachine.new(program)
  screen = ScreenReader.new(machine)
  machine.run
  screen.process
  screen.paint_display
  answer = screen.num_blocks
  puts "part 1: #{answer} blocks on screen"

  # part 2
  hacked_program = program.split(',').map(&:to_i)
  hacked_program[0] = 2
  cabinet = ArcadeCabinet.new(hacked_program)
  cabinet.run
  # notes: to save-scum, need to:
  #  - save IP, relative base, and all the memory
  #  - save to an auto-incrementing file so it doesn't overwrite
  #  - would be nice to save a screenshot of the game on further lines
  #    since the program itself is just the first line. then we could
  #    see what the game state is before loading.
end

__END__
1,380,379,385,1008,2151,549350,381,1005,381,12,99,109,2152,1102,1,0,383,1101,0,0,382,21002,382,1,1,21001,383,0,2,21101,37,0,0,1106,0,578,4,382,4,383,204,1,1001,382,1,382,1007,382,36,381,1005,381,22,1001,383,1,383,1007,383,21,381,1005,381,18,1006,385,69,99,104,-1,104,0,4,386,3,384,1007,384,0,381,1005,381,94,107,0,384,381,1005,381,108,1105,1,161,107,1,392,381,1006,381,161,1101,-1,0,384,1106,0,119,1007,392,34,381,1006,381,161,1102,1,1,384,20101,0,392,1,21102,19,1,2,21102,1,0,3,21101,0,138,0,1106,0,549,1,392,384,392,21002,392,1,1,21101,19,0,2,21102,3,1,3,21102,161,1,0,1106,0,549,1102,0,1,384,20001,388,390,1,21002,389,1,2,21101,0,180,0,1105,1,578,1206,1,213,1208,1,2,381,1006,381,205,20001,388,390,1,20102,1,389,2,21101,205,0,0,1105,1,393,1002,390,-1,390,1102,1,1,384,21002,388,1,1,20001,389,391,2,21102,1,228,0,1106,0,578,1206,1,261,1208,1,2,381,1006,381,253,21001,388,0,1,20001,389,391,2,21102,253,1,0,1106,0,393,1002,391,-1,391,1102,1,1,384,1005,384,161,20001,388,390,1,20001,389,391,2,21102,1,279,0,1105,1,578,1206,1,316,1208,1,2,381,1006,381,304,20001,388,390,1,20001,389,391,2,21101,0,304,0,1106,0,393,1002,390,-1,390,1002,391,-1,391,1101,1,0,384,1005,384,161,21001,388,0,1,21001,389,0,2,21102,1,0,3,21102,1,338,0,1106,0,549,1,388,390,388,1,389,391,389,20102,1,388,1,20101,0,389,2,21102,4,1,3,21101,365,0,0,1106,0,549,1007,389,20,381,1005,381,75,104,-1,104,0,104,0,99,0,1,0,0,0,0,0,0,236,16,16,1,1,18,109,3,22101,0,-2,1,22102,1,-1,2,21101,0,0,3,21102,1,414,0,1106,0,549,21202,-2,1,1,22102,1,-1,2,21102,429,1,0,1105,1,601,1202,1,1,435,1,386,0,386,104,-1,104,0,4,386,1001,387,-1,387,1005,387,451,99,109,-3,2105,1,0,109,8,22202,-7,-6,-3,22201,-3,-5,-3,21202,-4,64,-2,2207,-3,-2,381,1005,381,492,21202,-2,-1,-1,22201,-3,-1,-3,2207,-3,-2,381,1006,381,481,21202,-4,8,-2,2207,-3,-2,381,1005,381,518,21202,-2,-1,-1,22201,-3,-1,-3,2207,-3,-2,381,1006,381,507,2207,-3,-4,381,1005,381,540,21202,-4,-1,-1,22201,-3,-1,-3,2207,-3,-4,381,1006,381,529,22102,1,-3,-7,109,-8,2106,0,0,109,4,1202,-2,36,566,201,-3,566,566,101,639,566,566,1202,-1,1,0,204,-3,204,-2,204,-1,109,-4,2105,1,0,109,3,1202,-1,36,594,201,-2,594,594,101,639,594,594,20101,0,0,-2,109,-3,2105,1,0,109,3,22102,21,-2,1,22201,1,-1,1,21101,0,383,2,21102,1,195,3,21102,1,756,4,21101,0,630,0,1106,0,456,21201,1,1395,-2,109,-3,2105,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,2,2,0,2,0,0,0,0,2,2,0,2,2,2,0,2,2,2,2,0,0,2,0,2,0,0,0,2,2,2,2,2,0,1,1,0,2,0,0,2,2,2,0,0,2,0,0,2,0,2,0,0,2,2,0,0,2,0,0,2,2,2,0,2,0,2,2,2,0,1,1,0,2,2,0,2,2,0,2,0,0,0,2,0,2,0,0,2,0,2,0,0,2,2,2,2,0,2,2,2,0,0,0,2,0,1,1,0,0,0,0,2,0,0,2,2,0,0,2,2,0,2,0,2,2,0,2,2,2,0,0,0,2,2,2,2,0,2,2,2,0,1,1,0,2,0,0,0,0,0,0,0,2,2,2,2,0,2,2,2,2,2,0,2,2,0,2,0,0,0,2,2,2,0,2,0,0,1,1,0,2,0,2,2,2,2,2,0,0,2,0,0,0,2,0,2,2,0,0,2,0,2,2,2,2,0,2,0,0,0,0,0,0,1,1,0,2,2,0,0,0,2,0,0,0,2,2,0,2,2,2,0,2,2,2,0,2,2,2,2,2,2,2,0,2,2,2,2,0,1,1,0,0,2,0,2,2,2,2,0,0,2,2,0,0,2,0,0,2,0,0,2,2,0,0,2,0,2,2,0,0,2,0,2,0,1,1,0,2,2,2,2,0,2,0,2,2,0,2,2,2,2,0,0,0,0,0,0,0,2,2,2,2,2,0,2,0,0,0,2,0,1,1,0,2,0,0,0,2,0,0,2,0,0,2,0,0,0,2,2,2,2,2,0,2,0,2,0,2,0,2,0,0,2,2,0,0,1,1,0,0,2,0,2,0,0,2,0,2,0,2,2,2,0,2,0,2,2,2,2,2,0,0,2,2,2,2,0,2,2,2,0,0,1,1,0,2,2,2,2,0,0,2,2,0,0,2,0,0,0,2,0,0,2,2,0,0,2,2,0,2,2,0,2,2,2,2,2,0,1,1,0,2,2,2,0,0,2,2,0,2,2,0,0,2,2,0,0,0,2,2,0,2,2,2,0,2,2,2,2,2,2,2,2,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,41,18,64,4,35,69,87,3,61,92,57,18,62,5,79,85,93,19,49,29,82,55,89,89,54,81,9,18,83,31,88,84,91,60,30,80,76,17,43,67,53,1,87,74,50,67,38,2,13,58,18,4,4,46,61,32,48,76,53,56,73,93,20,24,80,69,13,67,19,15,13,29,16,92,21,20,22,82,83,21,51,54,13,97,7,78,96,6,9,63,21,66,62,6,57,2,83,63,26,49,13,8,72,52,67,51,17,52,34,89,37,76,10,62,28,41,79,62,28,48,29,85,52,35,45,25,66,25,84,34,12,34,64,34,54,13,53,82,51,89,14,15,7,32,58,64,26,21,70,38,5,73,91,9,95,62,69,5,41,66,89,17,65,88,18,15,82,53,86,59,12,70,26,75,31,54,44,86,36,89,97,94,4,4,46,84,49,7,38,40,93,28,20,18,6,37,35,68,51,71,12,26,47,30,98,76,14,82,36,5,7,90,20,71,20,69,83,70,37,53,37,68,74,50,49,85,83,34,35,43,54,43,41,23,29,75,85,70,52,83,74,72,49,75,64,61,28,69,15,74,20,38,96,96,22,64,23,91,50,11,80,55,66,47,88,5,18,18,55,8,92,20,42,98,37,82,5,1,11,32,41,86,93,49,56,37,64,45,79,24,26,82,49,47,43,56,51,17,11,18,36,86,49,38,58,33,97,65,56,86,57,23,74,70,58,50,29,14,20,5,78,54,20,90,39,95,80,3,29,50,47,74,25,98,98,66,1,13,50,38,48,97,89,20,78,74,5,23,45,44,65,31,5,44,71,91,86,81,86,87,28,1,71,38,19,34,16,92,92,2,71,93,12,97,87,33,86,26,15,81,88,85,98,10,27,42,26,20,78,4,42,62,57,38,84,27,21,54,55,34,63,41,7,18,93,18,27,94,83,85,92,97,43,21,12,91,17,96,56,60,15,93,3,13,39,85,49,8,39,54,54,66,44,7,23,98,2,1,3,9,1,85,88,27,82,15,5,67,43,93,23,35,57,57,24,11,65,12,61,44,40,76,60,60,45,8,24,34,91,22,38,34,33,69,8,75,7,3,19,35,39,73,64,79,50,89,75,29,96,59,26,64,30,90,15,68,18,71,31,6,84,15,80,3,43,71,65,54,16,79,38,58,81,73,53,21,13,18,49,72,66,58,74,4,78,19,73,51,97,93,53,53,57,34,89,57,49,13,7,16,44,42,49,26,85,31,72,13,19,30,22,12,39,92,98,26,17,46,25,78,77,94,40,74,90,52,2,51,33,16,6,55,66,82,10,6,7,96,98,43,10,42,34,15,9,92,64,15,18,13,8,72,37,20,76,72,90,48,65,55,5,65,66,50,44,76,97,61,72,24,23,33,91,68,31,29,63,51,98,83,6,53,43,14,71,98,50,5,81,49,72,56,58,77,14,74,51,66,77,31,2,3,45,37,25,53,78,3,74,76,26,72,74,86,96,98,90,71,61,95,85,68,68,89,85,47,82,59,28,60,6,44,33,97,67,51,13,90,77,63,49,27,22,6,49,68,33,15,39,83,51,66,85,57,8,75,13,37,39,78,52,31,83,8,26,35,65,25,11,69,71,3,91,6,66,88,82,10,59,28,30,66,60,26,19,87,62,14,97,9,94,42,27,5,90,73,81,67,13,71,67,77,28,48,36,17,29,91,53,87,9,23,20,77,61,76,549350
