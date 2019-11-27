#!/usr/bin/env ruby

require "pry"

def letter_counts(serial)
  counts = {}
  serial.split('').each do |letter|
    counts[letter] ||= 0
    counts[letter] += 1
  end
  double = 0
  triple = 0
  counts.each do |k, v|
    if v == 2
      double = 1
    elsif v == 3
      triple = 1
    end
  end
  return [double, triple]
end


def list_checksum(list_of_serials)
  sums = list_of_serials.map { |ser| letter_counts(ser) }.reduce(0) do |sums, item|
    [sums[0] + item[0], sums[1] + item[1]]
  end
  sums[0] * sums[1]
end

if __FILE__ == $0
  file = File.open("p2_1.txt")
  puts list_checksum(file.readlines)
end


