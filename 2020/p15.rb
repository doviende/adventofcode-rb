#!/usr/bin/env ruby
require "active_support/core_ext/object/blank"

class NumberGameCounter
  def initialize(starting_number_list)
    @start_nums = starting_number_list
    @current_num = nil
    @turns_for_nums = {} # record the turns a number is spoken
    @turn = 0
  end

  def find(place)
    # return the place-th spoken number in the sequence
    place.times { step }
    current
  end

  def current
    @current_num
  end

  def step
    @turn += 1
    # look at @current_num to see the last one spoken.
    # if it's in @turns_for_nums, with list of turns being length 1, then it was new,
    # so speak 0 and record it in current_num
    if @turn <= @start_nums.size
      speak(@start_nums[@turn - 1])
    elsif
      @turns_for_nums[@current_num].size == 1
      speak(0) # last number was newly spoken
    else
      diff2 = @turns_for_nums[@current_num][-1] - @turns_for_nums[@current_num][-2]
      speak(diff2)
    end
  end

  def speak(num)
    @current_num = num
    @turns_for_nums[num] ||= []
    @turns_for_nums[num].push @turn
  end
end

if __FILE__ == $0
  starting_numbers = DATA.readlines(chomp: true).first.split(",").map(&:to_i)
  counter = NumberGameCounter.new(starting_numbers)
  part1 = counter.find(2020)
  puts "part 1: the 2020th number spoken will be #{part1}"

  counter = NumberGameCounter.new(starting_numbers)
  part2 = counter.find(30000000)
  puts "part2: the 30000000th number spoken will be #{part2}"
end

__END__
0,6,1,7,2,19,20
