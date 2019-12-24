#!/usr/bin/env ruby

# problem: game of life.
# You receive a 5x5 grid with # = bug, . = empty
# A bug dies unless there's exactly 1 bug adjacent (4 adjacent spots)
# Empty gets a bug if it has exactly 1 or 2 bugs adjacent.
#
# Part 1 is to first find the first board state that has appeared twice,
# and then calculate a function on it:
# Going left to right in rows, top to bottom, each spot is worth 1, 2, 4, 8, etc,
# and we need to add the ones that have bugs on them. Basically a binary number
# with bugs as the ones.

class GameOfBugs
  def initialize(rows)
    @rows = rows
    @row_length = rows[0].size
    @board = rows.map{ |r| r.chars }.flatten.map { |ch| ch == "#" }
    @boardseen = {}
    @boardseen[@board] = true
  end

  def calc_next
    nextboard = []
    @board.each.with_index do |spot, i|
      sum = sum_adjacents(i)
      nextboard[i] = false
      if spot
        nextboard[i] = true if 1 == sum
      else
        nextboard[i] = true if (sum == 1 || sum == 2)
      end
    end
    @board = nextboard
    self.print
  end

  def sum_adjacents(pos)
    adjacents = []
    if pos % @row_length > 0
      adjacents << pos - 1
    end
    if pos % @row_length < @row_length - 1
      adjacents << pos + 1
    end
    if pos >= @row_length
      adjacents << pos - @row_length
    end
    if pos <= @board.size - @row_length - 1
      adjacents << pos + @row_length
    end
    sum = adjacents.map { |x| (x < 0 || x > (@board.size - 1)) ? nil : x }.compact.map { |idx| @board[idx] }.map { |x| x ? 1 : 0 }.sum
  end

  def run_until_dup
    loop do
      calc_next
      if @boardseen[@board]
        # found repeat
        break
      end
      @boardseen[@board] = true
    end
  end

  def score
    @board.each.with_index.map { |x, idx| 2**idx * (x ? 1 : 0) }.sum
  end

  def print
    @board.map { |x| x ? 1 : 0 }.each_slice(@row_length).map { |r| r*'' }.each { |r| puts r }
    puts ""
  end
end

if __FILE__ == $0
  input_rows = DATA.readlines(chomp: true)
  game = GameOfBugs.new(input_rows)
  puts "input: "
  game.print
  game.run_until_dup
  score = game.score
  puts "\noutput: "
  game.print
  puts "part 1: biodiversity score is #{score}"
end

__END__
..###
##...
#...#
#.#.#
.#.#.
