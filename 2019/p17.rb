#!/usr/bin/env ruby

require_relative 'intcode'
require 'pry'

class VacuumRobot < WrappedIntcodeMachine
  module RobotStatus
    AWAKE = 2
    ASLEEP = 1
  end

  def initialize(*args)
    @funcs = {
      "A" => "L,10,L,8,R,12\n",
      "B" => "L,6,R,8,R,12,L,6,L,8\n",
      "C" => "L,8,L,10,L,6,L,6\n",
      "main" => "B,A,B,C,A,C,A,B,C,A\n"
    }
    @cont_choice = "n\n"
    super(*args)
  end

  def set_wake(status=RobotStatus::AWAKE)
    program[0] = status
  end

  def define_func(name, func_string)
    @funcs[name] = func_string
  end

  def continuous(choice)
    @cont_choice = "#{choice}\n"
  end

  def run
    super
    @output_thread = Thread.new do
      line = ""
      loop do
        ch = output.gets.chomp.to_i
        if ch > 256
          puts "answer: #{ch} dust"
        end
        ch = ch.chr
        if ch == "\n"
          puts line
        else
          line << ch
        end
      end
    end
    @output_thread.join
  end

  def send_command(string)
    # convert each char of the command to ascii ord values,
    # and then send each one to the robot's input separately.
    string.chars.map(&:ord).map(&:to_s).each do |com|
      self.input.puts com
    end
  end

  def send_settings
    [@funcs['main'],
     @funcs['A'],
     @funcs['B'],
     @funcs['C'],
     @cont_choice].each { |msg| send_command(msg) }
  end
end

class AsciiControl
  module CameraIcon
    PIPE = "#"
    SPACE = "."
    BOT_UP = "^"
    BOT_LEFT = "<"
    BOT_RIGHT = ">"
    BOT_DOWN = "v"
    BOT_TUMBLE = "X"
  end

  def initialize(program)
    @robot = VacuumRobot.new(program)
    @camera_view = []
    @camera_points = []
  end

  def run
    @robot.reset
    @robot.set_wake
    @robot.send_settings
    @robot.run
  end

  def read_camera!
    # return list of intersection coordinates
    # 1) read camera output from robot.
    # 2) find list of coords of intersections in output
    # 3) calc alignments from coords.
    line = ""
    @camera_view = []
    @robot.reset
    @robot.run
    @robot.output.each_line do |ascii_number|
      char = ascii_number.to_i.chr
      if char == "\n"
        @camera_view << line
        line = ""
      else
        line << char
      end
    end
    display_camera
  end

  def display_camera
    @camera_view.each do |line|
      puts line
    end
  end

  def display_points
    @cam_points.each do |line|
      puts line*''
    end
  end

  def detect_intersections
    # save a list of intersections
    return if @camera_view.empty?
    intersections = []
    @cam_points = @camera_view.map { |line| line.split('') }
    @cam_points.each.with_index do |line, y|
      line.each.with_index do |val, x|
        if intersection?(x, y)
          intersections << [x, y]
        end
      end
    end
    display_points
    intersections
  end

  def intersection?(x, y)
    # return true if x, y is an intersection
    raise "no points" if @cam_points.empty?
    return false if point(x, y) != CameraIcon::PIPE
    neigh = neighbours(x, y)
    if neigh.each.map { |p| point(*p) }.all? { |x| x==CameraIcon::PIPE }
      @cam_points[y][x] = "O"
      return true
    end
    return false
  end

  def point(x, y)
    max_y = @cam_points.size - 1
    max_x = @cam_points[0].size - 1
    if x < 0 || x > max_x || y < 0 || y > max_y
      return nil
    end
    return @cam_points[y][x]
  end

  def neighbours(x, y)
    list = []
    [[-1, 0], [0, 1], [1, 0], [0, -1]].each do |dx, dy|
      list << [x + dx, y + dy]
    end
    return list
  end
end

class PieceCalc
  def initialize(path)
    @path = path
    @pieces = {
      "A" => "L,10,L,8,R,12",
      "B" => "L,6,R,8,R,12,L,6,L,8",
      "C" => "L,8,L,10,L,6,L,6"
    }
    @sequence = []
  end
  
  def calc_pieces(num_pieces)
    # return all 3 pieces that cover the path.
    # starting at the start of the path, we know we have to have a piece there.
    # for each piece size, count how many times that piece matches the path as a substring.
    # start greedily with the longest piece with at least one other match
    # see if the rest of the board can be covered with two.
    # If the rest can't be covered with two, then backtrack and drop one char.
    # Probably need to handle splitting numbers 12 --> 6,6

    # interesting strategy:  take out a piece...check all spots where it was removed. if
    # it was preceded or succeeded by the same char every time, add that char to the pattern and repeat
    # doing this, we get:
    # A = "L,10,L,8,R,12"
    # B = "L,6,R,8,R,12,L,6,L,8"
    # C = "L,8,L,10,L,6,L,6"
    first_list = next_piece_possibilities(@path)
    first_list.each do |first|
    end
  end

  def next_piece_possibilities(path)
    piece_list = []
    path.chars.each.with_index do |letter, i|
      next if i < 4
      piece = path[0,i+1]
      break if piece.size >= 20
      times = path.scan(/#{piece}/).size
      puts "matched #{piece} #{times} times" if times > 1
      piece_list << piece if times > 1
      break if times == 1
    end
    return piece_list
  end

  def subtract_piece(path, piece)
    i=0
    rest = ""
    loop do
      if path[i..-1].match(/^#{piece}/)
        i += piece.size
      else
        rest << path[i]
        i += 1
      end
      break if i == path.size
    end
    return rest
  end

  def sequence
    # return the sequence of the pieces A,B,C that covers the path.
    if @pieces.empty?
      calc_pieces
    end
    return @sequence unless @sequence.empty?
    
  end
end

if __FILE__ == $0
  # part 1
  # ascii display with lines of hashes. find all intersection points.
  # grid is (0,0) in top left. "alignment" of each intersection point is X * Y
  # give the sum of the alignments.
  program = DATA.readlines[0].chomp.split(',').map(&:to_i).freeze
  ctrl = AsciiControl.new(program.dup)
#  ctrl.read_camera!
#  inters = ctrl.detect_intersections
#  sum = inters.map { |x,y| x*y }.sum
#  puts "#{inters}"
#  puts "part 1: sum of alignments is #{sum}"

  # part 2:
  # - need to find a path around without falling off scaffolding
  # - get 3 functions
  # - each function has max 20 chars
  # - chars include numerical amount forward, {L,R}, or comma
  # - specify to robot the main routine consisting of functions {A,B,C},
  #    then specify each of A(), B(), and C().
  # - then say "y" or "n" for continuous video feed, prolly just say "n"
  # - after completing program, robot prints map and returns a big non-ascii value which is the answer.

  # program notes:
  # potential full path:
  path = "L,6,R,8,R,12,L,6,L,8,L,10,L,8,R,12,L,6,R,8,R,12,L,6,L,8,L,8,L,10,L,6,L,6,L,10,L,8,R,12,L,8,L,10,L,6,L,6,L,10,L,8,R,12,L,6,R,8,R,12,L,6,L,8,L,8,L,10,L,6,L,6,L,10,L,8,R,12"
  ctrl.run
  # repeating pieces:
  

end

__END__
1,330,331,332,109,3508,1102,1,1182,16,1101,0,1473,24,101,0,0,570,1006,570,36,1002,571,1,0,1001,570,-1,570,1001,24,1,24,1105,1,18,1008,571,0,571,1001,16,1,16,1008,16,1473,570,1006,570,14,21102,58,1,0,1105,1,786,1006,332,62,99,21102,1,333,1,21101,0,73,0,1106,0,579,1102,0,1,572,1101,0,0,573,3,574,101,1,573,573,1007,574,65,570,1005,570,151,107,67,574,570,1005,570,151,1001,574,-64,574,1002,574,-1,574,1001,572,1,572,1007,572,11,570,1006,570,165,101,1182,572,127,1002,574,1,0,3,574,101,1,573,573,1008,574,10,570,1005,570,189,1008,574,44,570,1006,570,158,1105,1,81,21102,340,1,1,1106,0,177,21101,477,0,1,1105,1,177,21102,514,1,1,21102,1,176,0,1106,0,579,99,21101,184,0,0,1106,0,579,4,574,104,10,99,1007,573,22,570,1006,570,165,101,0,572,1182,21102,375,1,1,21101,211,0,0,1105,1,579,21101,1182,11,1,21102,222,1,0,1105,1,979,21102,388,1,1,21102,233,1,0,1105,1,579,21101,1182,22,1,21101,0,244,0,1106,0,979,21102,401,1,1,21101,255,0,0,1106,0,579,21101,1182,33,1,21101,266,0,0,1106,0,979,21101,0,414,1,21102,1,277,0,1106,0,579,3,575,1008,575,89,570,1008,575,121,575,1,575,570,575,3,574,1008,574,10,570,1006,570,291,104,10,21101,0,1182,1,21101,0,313,0,1106,0,622,1005,575,327,1102,1,1,575,21102,1,327,0,1106,0,786,4,438,99,0,1,1,6,77,97,105,110,58,10,33,10,69,120,112,101,99,116,101,100,32,102,117,110,99,116,105,111,110,32,110,97,109,101,32,98,117,116,32,103,111,116,58,32,0,12,70,117,110,99,116,105,111,110,32,65,58,10,12,70,117,110,99,116,105,111,110,32,66,58,10,12,70,117,110,99,116,105,111,110,32,67,58,10,23,67,111,110,116,105,110,117,111,117,115,32,118,105,100,101,111,32,102,101,101,100,63,10,0,37,10,69,120,112,101,99,116,101,100,32,82,44,32,76,44,32,111,114,32,100,105,115,116,97,110,99,101,32,98,117,116,32,103,111,116,58,32,36,10,69,120,112,101,99,116,101,100,32,99,111,109,109,97,32,111,114,32,110,101,119,108,105,110,101,32,98,117,116,32,103,111,116,58,32,43,10,68,101,102,105,110,105,116,105,111,110,115,32,109,97,121,32,98,101,32,97,116,32,109,111,115,116,32,50,48,32,99,104,97,114,97,99,116,101,114,115,33,10,94,62,118,60,0,1,0,-1,-1,0,1,0,0,0,0,0,0,1,42,14,0,109,4,1201,-3,0,586,21001,0,0,-1,22101,1,-3,-3,21102,0,1,-2,2208,-2,-1,570,1005,570,617,2201,-3,-2,609,4,0,21201,-2,1,-2,1106,0,597,109,-4,2105,1,0,109,5,1202,-4,1,630,20101,0,0,-2,22101,1,-4,-4,21101,0,0,-3,2208,-3,-2,570,1005,570,781,2201,-4,-3,652,21001,0,0,-1,1208,-1,-4,570,1005,570,709,1208,-1,-5,570,1005,570,734,1207,-1,0,570,1005,570,759,1206,-1,774,1001,578,562,684,1,0,576,576,1001,578,566,692,1,0,577,577,21102,702,1,0,1105,1,786,21201,-1,-1,-1,1105,1,676,1001,578,1,578,1008,578,4,570,1006,570,724,1001,578,-4,578,21102,1,731,0,1105,1,786,1105,1,774,1001,578,-1,578,1008,578,-1,570,1006,570,749,1001,578,4,578,21101,0,756,0,1106,0,786,1106,0,774,21202,-1,-11,1,22101,1182,1,1,21102,774,1,0,1106,0,622,21201,-3,1,-3,1106,0,640,109,-5,2106,0,0,109,7,1005,575,802,21002,576,1,-6,21001,577,0,-5,1106,0,814,21101,0,0,-1,21101,0,0,-5,21101,0,0,-6,20208,-6,576,-2,208,-5,577,570,22002,570,-2,-2,21202,-5,55,-3,22201,-6,-3,-3,22101,1473,-3,-3,2102,1,-3,843,1005,0,863,21202,-2,42,-4,22101,46,-4,-4,1206,-2,924,21102,1,1,-1,1105,1,924,1205,-2,873,21101,35,0,-4,1105,1,924,1201,-3,0,878,1008,0,1,570,1006,570,916,1001,374,1,374,1201,-3,0,895,1102,1,2,0,2101,0,-3,902,1001,438,0,438,2202,-6,-5,570,1,570,374,570,1,570,438,438,1001,578,558,922,20102,1,0,-4,1006,575,959,204,-4,22101,1,-6,-6,1208,-6,55,570,1006,570,814,104,10,22101,1,-5,-5,1208,-5,37,570,1006,570,810,104,10,1206,-1,974,99,1206,-1,974,1102,1,1,575,21101,973,0,0,1106,0,786,99,109,-7,2105,1,0,109,6,21101,0,0,-4,21102,0,1,-3,203,-2,22101,1,-3,-3,21208,-2,82,-1,1205,-1,1030,21208,-2,76,-1,1205,-1,1037,21207,-2,48,-1,1205,-1,1124,22107,57,-2,-1,1205,-1,1124,21201,-2,-48,-2,1106,0,1041,21102,1,-4,-2,1105,1,1041,21102,1,-5,-2,21201,-4,1,-4,21207,-4,11,-1,1206,-1,1138,2201,-5,-4,1059,1201,-2,0,0,203,-2,22101,1,-3,-3,21207,-2,48,-1,1205,-1,1107,22107,57,-2,-1,1205,-1,1107,21201,-2,-48,-2,2201,-5,-4,1090,20102,10,0,-1,22201,-2,-1,-2,2201,-5,-4,1103,2101,0,-2,0,1106,0,1060,21208,-2,10,-1,1205,-1,1162,21208,-2,44,-1,1206,-1,1131,1106,0,989,21101,439,0,1,1105,1,1150,21101,477,0,1,1106,0,1150,21102,514,1,1,21102,1149,1,0,1106,0,579,99,21102,1157,1,0,1105,1,579,204,-2,104,10,99,21207,-3,22,-1,1206,-1,1138,1201,-5,0,1176,2102,1,-4,0,109,-6,2106,0,0,40,9,46,1,7,1,46,1,7,1,46,1,7,1,46,1,7,1,46,1,7,1,42,13,42,1,3,1,50,1,3,1,50,1,3,1,50,1,3,9,42,1,11,1,36,9,9,1,36,1,5,1,1,1,9,1,18,13,5,1,5,7,5,1,18,1,17,1,7,1,9,1,8,7,3,1,13,11,1,1,9,1,8,1,5,1,3,1,13,1,3,1,5,1,1,1,9,1,6,7,1,1,3,1,13,1,3,1,5,1,1,1,9,1,6,1,1,1,3,1,1,1,3,1,13,1,3,1,5,1,1,1,9,1,6,1,1,1,3,1,1,1,3,1,13,1,3,1,5,1,1,1,9,1,6,1,1,1,3,1,1,1,3,1,13,1,3,1,5,1,1,1,9,1,6,1,1,11,13,1,3,7,1,1,9,8,5,1,1,1,17,1,11,1,15,2,5,1,1,1,5,13,11,9,7,2,5,1,1,1,5,1,31,1,7,10,5,1,31,1,7,1,6,1,7,1,31,1,7,1,6,1,7,1,25,11,3,1,6,1,7,1,25,1,5,1,3,1,3,1,6,9,25,1,1,13,40,1,1,1,3,1,3,1,44,1,1,1,3,1,3,1,44,1,1,1,3,1,3,1,44,7,3,1,46,1,7,1,46,9,4
