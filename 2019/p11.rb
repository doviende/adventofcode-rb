#!/usr/bin/env ruby

# turtle-bot - intcode machine for a brain, and it moves 1 square
# ahead every turn. the brain tells it whether to turn left or right,
# and what color to paint the floor. input is what current color the
# floor is on the square it arrives on.

require_relative 'intcode'
require 'matrix'

class TurtleBot
  module Direction
    LEFT = 0
    RIGHT = 1
  end

  module Paint
    BLACK = 0
    WHITE = 1
  end

  TurnMatrix = {
    Direction::LEFT => Matrix[[0, -1], [1, 0]],
    Direction::RIGHT => Matrix[[0, 1], [-1, 0]]
  }.freeze
  
  def initialize(program)
    @program_text = program
    @brain_in = IO.pipe
    @brain_out = IO.pipe
    @brain = IntcodeMachine.new(program, @brain_in[0], @brain_out[1], nil)
    @brain_thread = nil
    @pos_list = []  # list of positions arrived at.
    @curr_pos = Matrix.column_vector([0, 0])
    @direction = Matrix.column_vector([0, 1])  # (x, y) added to position to get to next spot
    @floor_color = Hash.new { |hash, key| hash[key] = Paint::BLACK }  # default black color
  end

  def turn(dir)
    puts "funny dir: #{dir}" if TurnMatrix[dir].nil?
    @direction = TurnMatrix[dir] * @direction
  end
    
  def positions
    @pos_list
  end

  def write(x)
    @brain_in[1].puts x
  end

  def read
    result = @brain_out[0].gets
    return result.chomp.to_i unless result.nil?
    result
  end

  def advance
    @curr_pos = @curr_pos + @direction
    @pos_list.push(@curr_pos.transpose.to_a.flatten)
    @curr_pos
  end
  
  def run
    @brain_thread = Thread.new { @brain.run }
    loop do
      write(@floor_color[@curr_pos])
      new_floor = read
      break if new_floor.nil?  # intcode machine closes output if finished
      @floor_color[@curr_pos] = new_floor
      dir = read
      turn(dir)
      advance
      break unless @brain_thread.alive?
    end
  end
end

if __FILE__ == $0
  program = DATA.readlines[0].chomp.freeze
  turtle = TurtleBot.new(program)
  turtle.run
  unique_spots = turtle.positions.uniq
  puts "part 1: #{unique_spots.size} at least once"
end


__END__
3,8,1005,8,335,1106,0,11,0,0,0,104,1,104,0,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,0,8,10,4,10,102,1,8,28,3,8,1002,8,-1,10,1001,10,1,10,4,10,1008,8,1,10,4,10,101,0,8,51,1006,0,82,1006,0,56,1,1107,0,10,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,0,10,4,10,1001,8,0,83,3,8,1002,8,-1,10,101,1,10,10,4,10,108,1,8,10,4,10,101,0,8,104,1006,0,58,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,0,8,10,4,10,1001,8,0,129,1006,0,54,1006,0,50,1006,0,31,3,8,1002,8,-1,10,1001,10,1,10,4,10,1008,8,1,10,4,10,102,1,8,161,2,101,14,10,1006,0,43,1006,0,77,3,8,102,-1,8,10,1001,10,1,10,4,10,1008,8,0,10,4,10,102,1,8,193,2,101,12,10,2,109,18,10,1,1009,13,10,3,8,102,-1,8,10,101,1,10,10,4,10,108,1,8,10,4,10,102,1,8,226,1,1103,1,10,1,1007,16,10,1,3,4,10,1006,0,88,3,8,102,-1,8,10,101,1,10,10,4,10,108,1,8,10,4,10,1001,8,0,263,1006,0,50,2,1108,17,10,1006,0,36,1,9,8,10,3,8,1002,8,-1,10,101,1,10,10,4,10,1008,8,0,10,4,10,1002,8,1,300,1006,0,22,2,106,2,10,2,1001,19,10,1,3,1,10,101,1,9,9,1007,9,925,10,1005,10,15,99,109,657,104,0,104,1,21101,0,937268454156,1,21102,1,352,0,1106,0,456,21101,0,666538713748,1,21102,363,1,0,1105,1,456,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,21101,3316845608,0,1,21102,1,410,0,1105,1,456,21101,0,209475103911,1,21101,421,0,0,1106,0,456,3,10,104,0,104,0,3,10,104,0,104,0,21101,0,984353603944,1,21101,444,0,0,1105,1,456,21102,1,988220752232,1,21102,1,455,0,1106,0,456,99,109,2,22101,0,-1,1,21102,40,1,2,21101,487,0,3,21101,0,477,0,1106,0,520,109,-2,2105,1,0,0,1,0,0,1,109,2,3,10,204,-1,1001,482,483,498,4,0,1001,482,1,482,108,4,482,10,1006,10,514,1102,0,1,482,109,-2,2105,1,0,0,109,4,2101,0,-1,519,1207,-3,0,10,1006,10,537,21101,0,0,-3,22101,0,-3,1,22101,0,-2,2,21102,1,1,3,21101,556,0,0,1106,0,561,109,-4,2106,0,0,109,5,1207,-3,1,10,1006,10,584,2207,-4,-2,10,1006,10,584,21201,-4,0,-4,1106,0,652,22101,0,-4,1,21201,-3,-1,2,21202,-2,2,3,21101,0,603,0,1105,1,561,22101,0,1,-4,21102,1,1,-1,2207,-4,-2,10,1006,10,622,21102,1,0,-1,22202,-2,-1,-2,2107,0,-3,10,1006,10,644,21201,-1,0,1,21101,644,0,0,105,1,519,21202,-2,-1,-2,22201,-4,-2,-4,109,-5,2106,0,0
