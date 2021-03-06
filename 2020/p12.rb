#!/usr/bin/env ruby
require "active_support/core_ext/object/blank"

class Ship
  class BadDirectionError < StandardError; end
  class BadAngleError < StandardError; end

  Directions = [
    NORTH = "N",
    EAST = "E",
    SOUTH = "S",
    WEST = "W",
  ]
  LEFT = "L"
  RIGHT = "R"
  FORWARD = "F"

  attr_accessor :x, :y

  def initialize
    @dir = EAST # direction we are facing
    @x = 0
    @y = 0
  end

  def manhattan_distance
    # manhattan distance from starting point
    x.abs + y.abs
  end

  def move(desc)
    command = desc[0]
    argument = desc[1..].to_i
    return turn(command, argument) if [LEFT, RIGHT].include? command
    return forward(argument) if command == FORWARD

    translate(command, argument)
  end

  def forward(argument)
    translate(@dir, argument)
  end

  def translated
    self
  end

  def translate(command, argument)
    raise BadDirectionError unless Directions.include?(command)

    case command
    when NORTH
      translated.y += argument
    when SOUTH
      translated.y -= argument
    when EAST
      translated.x += argument
    when WEST
      translated.x -= argument
    end
  end

  def turn(command, argument)
    raise BadDirectionError unless [LEFT, RIGHT].include?(command)
    raise BadAngleError unless [90, 180, 270].include?(argument)

    amount = argument / 90
    if command == LEFT
      amount = -1 * amount
    end
    current_idx = Directions.index(@dir)
    dir_idx = (current_idx + amount) % 4
    @dir = Directions[dir_idx]
  end
end


class Part2Ship < Ship
  def initialize
    @x = 0
    @y = 0
    @waypoint = Waypoint.new
  end

  def forward(argument)
    @x += argument * @waypoint.x
    @y += argument * @waypoint.y
  end

  def translated
    @waypoint
  end

  def turn(command, argument)
    raise BadDirectionError unless [LEFT, RIGHT].include?(command)
    raise BadAngleError unless [90, 180, 270].include?(argument)

    if argument == 180
      @waypoint.flip
    elsif (argument == 90 && command == LEFT) || (argument == 270 && command == RIGHT)
      @waypoint.left
    else
      @waypoint.right
    end
  end
end

class Waypoint
  attr_accessor :x, :y

  def initialize
    @x = 10
    @y = 1
  end

  def left
    # rotate 90 left: (x, y) -> (-y, x)
    x_0 = @x
    y_0 = @y
    @x = -y_0
    @y = x_0
  end

  def right
    # rotate 90 right: (x, y) -> (y, -x)
    x_0 = @x
    y_0 = @y
    @x = y_0
    @y = -x_0
  end

  def flip
    # 180
    @x = -@x
    @y = -@y
  end
end

if __FILE__ == $0
  lines = DATA.readlines(chomp: true)
  ship = Ship.new
  lines.each do |desc|
    ship.move(desc)
  end
  puts "part 1: ship ends #{ship.manhattan_distance} away from the start"
  ship = Part2Ship.new
  lines.each do |desc|
    ship.move(desc)
  end
  puts "part 2: ship ends #{ship.manhattan_distance} away from the start"
end

__END__
R90
F88
R180
F98
S5
F14
S4
L270
S1
R90
F34
R90
F96
N1
E5
F94
R90
N1
E1
R90
S5
F59
S2
L90
E2
L90
S1
W3
N2
L90
S1
F32
F92
N1
F10
E2
F92
N1
E4
F68
W1
R90
F53
N3
F29
S1
R180
W5
R90
E1
F79
W2
R90
F70
S2
F17
S5
S3
F41
N4
E5
F65
E1
N4
E4
S3
F1
N1
E5
F73
S5
F4
L90
F100
E2
S5
E2
F67
N3
F27
S4
E4
F12
S4
W3
W2
F10
L90
N5
E2
R90
W4
F76
S5
F48
R90
F28
L90
F36
N4
F27
E4
N3
F12
L90
S1
R180
S2
F77
E2
N5
E3
S2
E1
L90
E5
W4
F3
W4
L90
N2
E1
F61
W4
F12
N2
F41
W2
W4
L90
W3
F42
S5
W4
N5
E5
F94
W5
R90
W3
R90
E2
S3
L90
E1
S4
W1
L90
E4
F57
S3
S4
W4
S1
W2
F22
W5
L180
F93
R90
N2
R90
E5
R180
E5
F22
R90
F61
E4
L180
E2
L90
W5
L90
N1
E1
N3
W3
L90
N2
W4
S1
L180
W5
S4
F69
R90
N2
R90
N3
R90
F100
S2
L180
F13
S4
E3
L90
F88
W3
N4
R90
W3
R90
F19
E4
F28
W3
R90
N2
F5
W4
F88
S3
L180
F14
N4
R180
W3
N1
F87
N2
F73
S1
F53
N1
L90
S2
L180
W5
N2
L90
R90
F1
L90
E1
R90
N3
F73
E4
F58
S5
E3
E4
F88
L90
E3
L90
F8
N2
W3
F62
S3
F25
E3
N5
F24
F21
W1
S3
W3
F18
S5
F93
L90
N3
L180
S5
F55
W1
F38
L90
E2
L180
F66
S3
F55
R90
N5
R90
F31
R90
F70
L90
E3
L90
E1
F95
W3
E5
L90
F58
R90
F26
R90
L180
N1
F14
L90
N4
E5
S2
E1
R90
W5
S5
L90
S5
R270
F96
L90
W3
F48
S5
W4
F76
L90
S3
W5
S3
F71
S1
F96
N4
R90
E5
F16
L270
N2
L90
N2
R90
S1
N2
R90
F13
L90
N2
L90
F67
R180
F26
R270
R270
W1
S4
R180
E2
F86
S5
E5
N4
W5
N4
L90
E4
F96
R180
F61
W4
L90
F45
L90
F62
E4
N5
E4
R90
N3
L90
F53
N4
W1
L90
F82
F33
N3
F24
R90
F97
E3
F13
N5
R90
W4
N1
E5
L90
E2
L180
S2
F41
N1
E2
S1
F98
E2
R180
F70
N4
F33
N5
F64
R180
W1
R180
F24
N1
L180
W1
L90
E1
N3
E1
L90
W3
S5
E4
L90
W1
F26
L90
N1
W2
F22
W4
S1
R90
S3
R90
F7
E1
S5
W5
L180
F55
E4
N5
R90
F29
L90
S3
F9
S4
R270
F72
W4
N3
L180
W2
L90
S4
F84
N1
F40
N3
F100
N5
R180
S4
R90
S2
L90
W1
N5
E4
S5
R90
F23
L90
E4
E1
R180
S2
F81
S5
E1
E1
R90
F72
N2
W4
S3
L180
N5
W2
F50
W5
F28
L90
E3
R90
N2
N2
L90
N5
F84
N5
F85
W3
L90
F55
E2
R90
W5
R90
W1
F4
N4
L180
N1
E1
R180
E4
L270
E5
R90
F60
N1
W5
N3
E5
R90
F73
E3
N4
W1
F32
R90
E3
L90
F91
E3
S3
W2
L90
E1
L90
E1
N5
L180
F87
W3
N4
F78
W5
L90
F34
N4
R90
E5
R180
N2
F52
W4
L90
E1
F17
S2
E3
L180
E3
E2
N5
E5
R90
S1
W3
N5
L90
W1
F13
W4
S4
N5
E5
S4
F26
E5
F59
W1
N4
S4
L90
F85
L90
W5
R90
S1
E2
F86
R90
S2
R90
F72
L270
W5
W4
L90
N2
R90
F12
R90
F21
R180
S4
L180
E5
R90
S5
W5
F87
E3
R90
E3
S1
L270
F74
R90
S3
W5
F3
R90
W2
L90
F11
S2
W3
R90
S3
N1
W4
F67
S1
E2
N4
L270
E5
L90
N1
E2
F75
E1
L90
F63
E4
R90
S4
F62
N5
E4
N4
F65
S2
W2
F15
R90
W3
W5
F71
R90
S1
L90
S1
F43
S3
F82
L90
F7
W1
S3
E2
E1
S1
F74
R90
N4
E4
F12
W2
L180
S2
E2
S1
F5
N5
W5
N5
S1
W5
F42
S5
L90
N2
F2
W2
R90
S4
L180
F53
W5
R90
F38
L90
W3
W3
F50
R90
N4
F25
E1
N5
E4
S3
F50
L90
E2
R180
F31
S1
E5
F46
L90
E3
F88
L90
F95
N4
F57
S4
E4
R270
R90
E5
F11
R90
N5
L90
F54
N2
W2
F32
N4
R270
S2
F44
R90
R90
W4
L90
F78
F42
W1
R90
N5
F83
W2
L90
W3
L180
S1
R90
F38
S5
N2
F46
W3
F83
W3
R90
F41
W1
R180
E4
N1
F39
F36
S3
L90
E3
F42
N3
E4
F60
