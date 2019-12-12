#!/usr/bin/env ruby

# N-body problem
# * 4 moons
# * each moon has 3D position and 3D velocity
# each step:
#   * update velocity of each moon
#   * apply velocity to update position
#   * time ticks +1

# Gravity
# * each pair of moons, for each axis:
#   if their position in that axis is not the same, then
#   do either +1 or -1 to their velocity in that axis
#   to move them towards each other.
# Velocity
# * after gravity has been applied to change velocities,
#   apply the velocities to the positions.

# Energy
# Moons have potential and kinetic energy values.
# Potential = sum of abs of x, y, z position values.
# Kinetic = sum of abs of x, y, z velocity values.
# "Total Energy" of a moon is potential * kinetic.

# Answer
# calculate the "total energy" of the whole system after simulating
# moons for 1000 steps.

require 'matrix'

class Moon
  attr_accessor :position, :velocity
  
  def initialize(line)
    # line is like: "<x=-8, y=-9, z=-7>"
    @position = Matrix.row_vector(self.parse(line))
    @velocity = Matrix.row_vector([0,0,0])
  end

  def parse(line)
    # line is like: "<x=-8, y=-9, z=-7>"
    m = line.match /<x=([^,]*), y=([^,]*), z=([^>]*)>/
    m.captures.map(&:to_i)
  end

  def add_velocity(arr)
    @velocity += Matrix.row_vector(arr)
  end

  def potential
    @position.map { |i| i.abs }.sum
  end

  def kinetic
    @velocity.map { |i| i.abs }.sum
  end

  def total_energy
    potential * kinetic
  end

  def advance!
    # apply velocity to position to move the moon one step.
    @position += @velocity
  end

  def hash_key
    @position.to_a*'' + @velocity.to_a*''
  end
end

class Simulator
  attr_reader :time
  
  def initialize
    @moons = []
    @time = 0
    @states = {}
  end

  def add_moon(moon)
    @moons.push moon
  end

  def run(steps)
    # for each pair of moons, apply gravity
    steps.times do
      @moons.combination(2).each do |m1, m2|
        do_a_gravity!(m1, m2)
      end
      @moons.each(&:advance!)
      @time += 1
    end
  end

  def run_until_same
    # run until current state matches any previous state
    @states[calc_hash] = true
    loop do
      run(1)
      state_hash = calc_hash
      break if @states[state_hash]
      @states[state_hash] = true
      puts "time: #{@time}" if @time % 1000 == 0
    end
  end

  def energy
    @moons.reduce(0) do |sum, moon|
      sum + moon.total_energy
    end
  end

  private

  def calc_hash
    @moons.map(&:hash_key)*''
  end

  def do_a_gravity!(m1, m2)
    # interact two moons via the gravity formula
    v1 = []
    v2 = []
    (0..2).each do |dim|
      diff = m2.position[0,dim] - m1.position[0,dim]
      diff = 1 if diff > 0
      diff = -1 if diff < 0
      v1[dim] = diff
      v2[dim] = -diff
    end
    m1.add_velocity(v1)
    m2.add_velocity(v2)
  end
end

if __FILE__ == $0
  sim = Simulator.new
  DATA.readlines(chomp: true).each do |mline|
    sim.add_moon(Moon.new(mline))
  end
  num_steps = 1000
  sim.run(num_steps)
  puts "part 1: total energy after #{num_steps} steps is #{sim.energy}"

  sim.run_until_same
  puts "part 2: same after #{sim.time} steps"
end

__END__
<x=-8, y=-9, z=-7>
<x=-5, y=2, z=-1>
<x=11, y=8, z=-14>
<x=1, y=-4, z=-11>
