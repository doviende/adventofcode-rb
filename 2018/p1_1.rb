#!/usr/bin/env ruby

file = File.open("p1_1.txt")
total = file.readlines.reduce(0) do |sum, i|
  sum + i.to_i
end

puts total
