#!/usr/bin/env ruby

# for each asteroid point, find out how many asteriods are visible
# on line of sight. asteroids only hide other asteriods that are
# directly behind them

class Map
  def initialize(map_lines)
    # expects array of hashes and dots, one element per line
    @lines = map_lines.map { |line| line.chars.map { |x| x == '#' } }
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
    aligned = aligned_hash(x, y)
    total = aligned.values.reduce(0) do |sum, slope_list|
      if slope_list.size > 0
        sum + 1
      else
        sum
      end
    end
    total
  end

  def aligned_hash(x, y)
    aligned = Hash.new { |hash, key| hash[key] = [] }
    (0 .. max_y).each do |b|
      (0 .. max_x).each do |a|
        if [a, b] != [x, y]
          slope = Slope.new(a, b, x, y).as_pair
          #if aligned[slope]
          #  $stderr.puts "already seen (#{a}, #{b}) at #{slope}"
          #end
          aligned[slope] << [a, b] if asteroid(a, b)
        end
      end
    end
    aligned
  end
end

class Slope
  def initialize(a, b, x, y)
    # a-x, b-y
    # $stderr.puts "comparing (#{a}, #{b}) to base (#{x}, #{y})"
    @dx = a-x
    @dy = b-y
    @gcd = @dx.gcd(@dy)
    if @dx == 0 && @dy == 0
      @gcd = 1
    end
  end

  def as_pair
    [@dy/@gcd, @dx/@gcd]
  end
end

if __FILE__ == $0
  map = Map.new(DATA.readlines(chomp: true))
  puts "part 1: #{map.most_visible[1]}"

  # part 2
  # Have to rotate around zapping asteroids one at a time, sheltered ones don't get hit.
  # rotation starts at -y, 0 and rotates through -y +x to 0 +x, etc.
  # for each quadrant, select that quadrant's asteroids in the hash, and (in order)
  # subtract 1 from each one. Keep going until the 200th zap.
  map.zap!(199)
  point = map.next_zap
  answer = 100*point[0] + point[1]
  puts "part 2: #{answer}"
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
