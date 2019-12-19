#!/usr/bin/env ruby

# - program runs a "drone ship" to check for tractor beam effect
# - give two inputs for X and Y for ship to be deployed at - zero or positive
# - program will output 0 for "not being pulled", and 1 for "being pulled"
# - (0,0) is right in front of the beam, so it will always be true there.
#
# Part 1 GOAL: find the number of points in a 50x50 grid where the tractor beam is in effect.

require_relative 'intcode'
require 'pry'

class DroneShip < WrappedIntcodeMachine
  # it appears the drone program just goes to the one spot and then ends.
  def initialize(program)
    super(program)
    @current = false
    @done = false
  end
  
  def go(x, y)
    raise "no negatives" if x < 0 || y < 0
    raise "already done, only once" if @done
    self.input.puts "#{x}"
    self.input.puts "#{y}"
    @current = (self.output.gets.chomp.to_i == 1)
    kill_thread
    @done = true
  end

  def current
    @current
  end
end

class DroneController
  attr_reader :program
  def initialize(program)
    @drone = nil
    @program = program
  end

  def send_drone(x, y)
    @drone = DroneShip.new(program)
    @drone.run
    @drone.go(x,y)
    @drone.current
  end

  def trace_beam(x_size, y_size)
    # return count of positions with tractor beam == true
    # naive: just check all:
    count = 0
    (0..y_size-1).each do |y|
      line = ""
      (0..x_size-1).each do |x|
        val = send_drone(x,y)
        if val
          line << "#"
          count += 1
        else
          line << "."
        end
      end
      puts line
    end
    count
  end
end

if __FILE__ == $0
  program = DATA.readlines[0].chomp
  drone_ctl = DroneController.new(program.dup)
  count = drone_ctl.trace_beam(50,50)
  puts "part 1: #{count} covered by beam inside (50,50)"
end


# stupid debug:
# having problems with instruction  21201  - add relative to immediate and store in relative.
#intcode machine error, shit.  undefined method `+' for nil:NilClass
#IP: 239 | add [nil, 0, 0]
#param | mode: relative value: -1 relative: 439
#param | mode: immediate value: 0 relative: 439
#param | mode: relative value: 3 relative: 439
# @program.size = 442 but i notice 438 and 439 are set to nil, so apparently the add function here
# is not necessarily the problem, but maybe something else storing a nil.
# I then added a "_store()" function to find the spot where the nil is being written...but it was never writing a nil
# So it seems that it's just that when we put the stack pointer way high, and then work backwards, we hit
# empty spots in the array that are nil.
# Turns out .fetch doesn't do what i thought on arrays in ruby.


__END__
109,424,203,1,21102,11,1,0,1105,1,282,21101,0,18,0,1105,1,259,2102,1,1,221,203,1,21102,1,31,0,1105,1,282,21102,1,38,0,1105,1,259,21002,23,1,2,21201,1,0,3,21101,0,1,1,21102,57,1,0,1105,1,303,2102,1,1,222,21002,221,1,3,21001,221,0,2,21102,1,259,1,21102,80,1,0,1105,1,225,21102,59,1,2,21102,1,91,0,1105,1,303,1202,1,1,223,21001,222,0,4,21102,259,1,3,21102,1,225,2,21101,225,0,1,21101,118,0,0,1105,1,225,21002,222,1,3,21102,1,112,2,21101,0,133,0,1105,1,303,21202,1,-1,1,22001,223,1,1,21101,148,0,0,1105,1,259,1201,1,0,223,20102,1,221,4,21002,222,1,3,21102,1,18,2,1001,132,-2,224,1002,224,2,224,1001,224,3,224,1002,132,-1,132,1,224,132,224,21001,224,1,1,21101,0,195,0,106,0,108,20207,1,223,2,21001,23,0,1,21102,1,-1,3,21102,1,214,0,1105,1,303,22101,1,1,1,204,1,99,0,0,0,0,109,5,2101,0,-4,249,22101,0,-3,1,21202,-2,1,2,21201,-1,0,3,21101,250,0,0,1105,1,225,22101,0,1,-4,109,-5,2105,1,0,109,3,22107,0,-2,-1,21202,-1,2,-1,21201,-1,-1,-1,22202,-1,-2,-2,109,-3,2106,0,0,109,3,21207,-2,0,-1,1206,-1,294,104,0,99,21202,-2,1,-2,109,-3,2105,1,0,109,5,22207,-3,-4,-1,1206,-1,346,22201,-4,-3,-4,21202,-3,-1,-1,22201,-4,-1,2,21202,2,-1,-1,22201,-4,-1,1,22102,1,-2,3,21101,343,0,0,1106,0,303,1105,1,415,22207,-2,-3,-1,1206,-1,387,22201,-3,-2,-3,21202,-2,-1,-1,22201,-3,-1,3,21202,3,-1,-1,22201,-3,-1,2,22102,1,-4,1,21101,384,0,0,1105,1,303,1105,1,415,21202,-4,-1,-4,22201,-4,-3,-4,22202,-3,-2,-2,22202,-2,-4,-4,22202,-3,-2,-3,21202,-4,-1,-2,22201,-3,-2,1,22102,1,1,-4,109,-5,2106,0,0
