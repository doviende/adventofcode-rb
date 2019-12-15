#!/usr/bin/env ruby
require 'pry'
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
    [@position.to_a, @velocity.to_a].hash
  end
end

class Simulator
  attr_reader :time
  
  def initialize
    @moons = nil
    @moons_original = []
    @time = 0
    @answer = nil
    @all_hashes = nil
  end

  def common_repeat
    @answer[0].lcm(@answer[1]).lcm(@answer[2])
  end

  def add_moon(moon)
    @moons_original.push moon
  end

  def reset
    @moons = []
    @moons_original.each do |m|
      @moons << m.dup
    end
    @answer = [nil, nil, nil]
    @all_hashes = [Hash.new(false), Hash.new(false), Hash.new(false)]  # only need to check repeats individually per dimension
    @time = 0
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
    # find when each dimension repeats, since they are independent
    check_repeats
    loop do
      run(1)
      puts "time: #{@time}" if @time % 1000 == 0
      check_repeats
      break if all_repeats_found
    end
  end

  def check_repeats
    [0,1,2].each do |dim|
      if @answer[dim].nil?
        val = dim_hash(dim)
        if @all_hashes[dim][val]
          @answer[dim] = @time
          puts "found answer for #{['x', 'y', 'z'][dim]} at #{@time}"
        else
          @all_hashes[dim][val] = true
        end
      end
    end
  end

  def all_repeats_found
    !(@answer[0].nil? || @answer[1].nil? || @answer[2].nil?)
  end

  def energy
    @moons.reduce(0) do |sum, moon|
      sum + moon.total_energy
    end
  end

  private

  def dim_hash(dim)
    # hash all x positions and x velocities
    dim_array = @moons.reduce([]) do |sum, m|
      sum << m.position[0, dim]
      sum << m.velocity[0, dim]
    end
    dim_array.hash
  end

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
  sim.reset
  sim.run(num_steps)
  puts "part 1: total energy after #{num_steps} steps is #{sim.energy}"

  sim.reset
  sim.run_until_same
  puts "part 2: same after #{sim.common_repeat} steps"
end

__END__
<x=-8, y=-9, z=-7>
<x=-5, y=2, z=-1>
<x=11, y=8, z=-14>
<x=1, y=-4, z=-11>
