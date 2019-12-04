#!/usr/bin/env ruby

# It is a six-digit number.
# The value is within the range given in your puzzle input.
# Two adjacent digits are the same (like 22 in 122345).
# Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).

# How many different passwords within the range given in your puzzle input meet these criteria?

def find_all_passwords(first, last)
  return (first .. last).select { |x| two_adjacent(x) && digits_increase(x) }.size
end

def two_adjacent(x)
  # return true if at least two adjacent digits in x are the same
  same = x.digits(10).each_cons(2).detect { |a,b| a == b }
  !same.nil?
end

def digits_increase(x)
  # return true if the digits in order are the same or increasing left to right
  # .digits() goes right to left.
  # check for negative condition not existing
  x.digits(10).each_cons(2).detect { |a,b| a < b }.nil?
end

if __FILE__ == $0
  input_range = [109165, 576723]
  num = find_all_passwords(input_range[0], input_range[1])
  puts "part 1: #{num} passwords match the criteria in that range"
end
