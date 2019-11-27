#!/usr/bin/env ruby

def differ_by_one(pair)
  return false if pair[0] == pair[1]
  count = 0
  other = pair[1].split('')
  pair[0].split('').each_with_index do |char, i|
    count += 1 if char != other[i]
    return false if count > 1
  end
  true if count == 1    
end

def subtract_diff(pair)
  pair[0].split('').zip(pair[1].split('')).map do |x,y|
    if x == y
      x
    else
      nil
    end
  end.compact.join
end

if __FILE__ == $0
  file = File.open("p2_2.txt")
  file.readlines.repeated_combination(2) do |pair|
    if differ_by_one(pair)
      puts subtract_diff(pair)
    end
  end
end
