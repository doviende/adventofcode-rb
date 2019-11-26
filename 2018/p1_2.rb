#!/usr/bin/env ruby

# +1, -1 first reaches 0 twice.
# +3, +3, +4, -2, -4 first reaches 10 twice.
# -6, +3, +8, +5, -6 first reaches 5 twice.
# +7, +7, -2, -7, -4 first reaches 14 twice.
# What is the first frequency your device reaches twice?

file = File.open("p1_2.txt")

def find_dup(list)
  seen = { 0 => true }
  dup = nil
  current = 0
  loop do
    current = list.reduce(current) do |sum, i|
      sum = sum + i.to_i
      return sum if seen[sum]
      seen[sum] = true
      sum
    end
  end
end  

puts find_dup(file.readlines)
#puts find_dup(["+1", "-1"])
#puts find_dup(["+3", "+3", "+4", "-2", "-4"])
