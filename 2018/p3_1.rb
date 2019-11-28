#!/usr/bin/env ruby

require 'pry'

class Sector
  attr_accessor :id, :x, :y, :width, :height

  def initialize(string)
    self.id, self.x, self.y, self.width, self.height = Sector.parse_string(string)
  end

  def self.parse_string(string)
    idpart, otherpart = string.split("@").map(&:strip)
    start, size = otherpart.split(":").map(&:strip)
    # id, x, y, width, height
    return [idpart.split("#")[1].strip.to_i,
            start.split(",").map(&:strip).map(&:to_i),
            size.split("x").map(&:strip).map(&:to_i)].flatten
  end

  def biggest_x
    x+width
  end

  def biggest_y
    y+height
  end

  def cover(grid)
    # add 1 on each spot in grid covered by this Sector
    full_sector do |xn, yn|
        grid[xn][yn] += 1
    end
  end

  def is_unique_cover(grid)
    # return true if all the grid values are exactly 1
    result = true
    full_sector do |xn, yn|
      result = false if grid[xn][yn] != 1
    end
    result
  end

  def full_sector(&block)
    (x..(x+width-1)).each do |x_loc|
      (y..(y+height-1)).each do |y_loc|
        yield [x_loc, y_loc]
      end
    end
  end
end

def count_doubles(grid)
  # return the number of squares that have coverage greater than 1
  grid.reduce(0) do |sum, col|
    sum + col.count { |x| x > 1 }
  end
end

def find_unique(grid, input)
  input.each do |sector|
    return sector.id if sector.is_unique_cover(grid)
  end
  nil
end

def main(line_list)
  # input lines: #1286 @ 512,253: 17x10
  input = line_list.map { |line| Sector.new(line) }
  maxes = input.reduce([0,0]) do |accum, sector|
    max_x = [accum[0], sector.biggest_x].max
    max_y = [accum[1], sector.biggest_y].max
    [max_x, max_y]
  end
  #puts "Maxes: #{maxes}"
  grid = Array.new(maxes[0]+1) { Array.new(maxes[1]+1, 0) }

  input.each do |sector|
    sector.cover(grid)
  end
  answer_1 = count_doubles(grid)
  # puts grid.map { |col| col.join(' ') }.join("\n")
  answer_2 = find_unique(grid, input)
  return [answer_1, answer_2]
end


if __FILE__ == $0
  file = File.open("p3_1.txt")
  puts main(file.readlines)
end
