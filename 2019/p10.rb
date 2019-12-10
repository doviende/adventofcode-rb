#!/usr/bin/env ruby

# for each asteroid point, find out how many asteriods are visible
# on line of sight. asteroids only hide other asteriods that are
# directly behind them

class Map
  def initialize(map_lines)
    # expects array of hashes and dots, one element per line
    @lines = map_lines.map { |line| line.chars.map { |x| x=='#' } }
    @line_hash = {}
  end

  def most_visible
    # return position and visible number for the best position
    # (ie the spot that sees the most asteroids)
    all_visible.sort_by { |loc, num| num }.pop
  end

  def all_visible
    # return a list, one element per asteroid, that is
    # the position and num seen for that asteroid.
    # e.g. [ [[2,3], 5], [[5,7], 3] ]
    accum = []
    @lines.each.with_index do |line, y|
      line.each.with_index do |spot, x|
        num = num_seen(x,y)
        accum << [[x,y], num] unless num.nil?
      end
    end
    accum
  end

  def max_y
    @lines.size - 1
  end

  def max_x
    @lines.first.size - 1
  end

  def asteroid(x, y)
    @line_hash[[x,y]] ||= @lines[y][x]
  end
  
  def num_seen(x, y)
    # looking from x,y, how many do we see that aren't blocked?
    # --> for each other point, if it's an asteroid, put it into a hash
    # where the key is the reduced slope from (x,y). This makes
    # asteroids "line up", and then we take the closest one.
    # Note: need to make sure the sign is correct so we don't mix
    # up the direction we're looking.
    return nil unless asteroid(x, y)
    aligned = {}
    (0 .. max_y).each do |b|
      (0 .. max_x).each do |a|
        if [a, b] != [x, y]
          aligned[Slope.new(a, b, x, y).as_pair] = 1 if asteroid(a, b)
        end
      end
    end
    aligned.values.sum
  end
end

class Slope
  def initialize(a, b, x, y)
    # a-x, b-y
    @dx = diff(a,x)
    @dy = diff(b,y)
  end

  def as_pair
    [@dy, @dx]
  end

  def diff(a, b)
    return 0 if a == 0 && b == 0
    (a-b) / a.gcd(b)
  end
end

if __FILE__ == $0
  map = Map.new(DATA.readlines(chomp: true))
  puts "part 1: #{map.most_visible[1]}"
end


__END__
##.##..#.####...#.#.####
##.###..##.#######..##..
..######.###.#.##.######
.#######.####.##.#.###.#
..#...##.#.....#####..##
#..###.#...#..###.#..#..
###..#.##.####.#..##..##
.##.##....###.#..#....#.
########..#####..#######
##..#..##.#..##.#.#.#..#
##.#.##.######.#####....
###.##...#.##...#.######
###...##.####..##..#####
##.#...#.#.....######.##
.#...####..####.##...##.
#.#########..###..#.####
#.##..###.#.######.#####
##..##.##...####.#...##.
###...###.##.####.#.##..
####.#.....###..#.####.#
##.####..##.#.##..##.#.#
#####..#...####..##..#.#
.##.##.##...###.##...###
..###.########.#.###..#.
