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
        nextboard[i] = true if sum == 1
      else
        nextboard[i] = true if (sum == 1 || sum == 2)
      end
    end
    @board = nextboard
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

class BugBoard
  attr_accessor :inner, :outer

  def initialize(inner: nil, outer: nil, size: 5)
    raise "size not odd" if size % 2 == 0
    @inner = inner
    @outer = outer
    @rows = empty_board(size)
    @size = size
  end

  def empty_board(size)
    board = []
    size.times do
      board << [false] * size
    end
  end

  def set_board(boolrows)
    @rews = []
    boolrows.each |r| do
      @rows << r.dup
    end
  end

  def set_loc(x, y, value)
    @rows[y][x] = value
  end

  def get_loc(x, y)
    @rows[y][x]
  end

  def num_bugs
    # should have center spot always false
    @rows.reduce(0) do |sum, row|
      sum + row.map { |x| x ? 1 : 0 }.sum
    end
  end

  def needs_outer
    # true if any edges are 1
    return false unless self.outer.nil?
    return true if @rows[0].any?
    return true if @rows[@size - 1].any?
    sides_any = @rows.reduce(0) do |sum, r|
      sum || r[0] || r[@size - 1]
    end
    sides_any
  end

  def needs_inner
    # true if any spots around center are 1
    return false unless self.inner.nil?
    center = @size / 2
    return get_loc(center - 1, center) ||
           get_loc(center + 1, center) ||
           get_loc(center, center + 1) ||
           get_loc(center, center - 1)
  end

  def calc_next
  end

  def set_next
  end

  # some easy funcs for checking neighbour spots on inner and outer?
  # because if outer is nil, then outer_top should be false (empty)
  # Need to be able to evaluate the same even if the next thing over hasn't
  # been created yet.
end

class RecursiveBugs
  def initialize(rows)
    @init_rows = rows
    rows = @init_rows.map do |r|
      r.chars.map { |x| x == "#" }
    end
    @boards = []
    @boards << BugBoard.new().set_board(rows)
  end

  def step
    @boards.each { |b| make_inner(b) if b.needs_inner }
    @boards.each { |b| make_outer(b) if b.needs_outer }
    @boards.each { |b| b.calc_next }
    @boards.each { |b| b.set_next }
  end

  def make_board(dir, board)
    board.send("#{dir}=", BugBoard.new)
    @boards << board.send("#{dir}")
  end

  def make_inner(board)
    make_board(:inner, board)
  end

  def make_outer(board)
    make_board(:outer, board)
  end

  def num_bugs
    @boards.map { |b|.num_bugs }.sum
  end
end

if __FILE__ == $0
  # part 1 - regular grid, what's the board score after it has repeated a state once?
  input_rows = DATA.readlines(chomp: true)
  game = GameOfBugs.new(input_rows.dup)
  puts "input: "
  game.print
  game.run_until_dup
  score = game.score
  puts "\noutput: "
  game.print
  puts "part 1: biodiversity score is #{score}"

  # part 2: recursive board.
  # There are infinite levels. middle square represents the next inner level.
  # Edge squares touch outer level.
  # Each left edge square at this level touches the same square to the left
  # on the outer level.
  # Otherwise, rules apply as normal.
  # How many bugs are there in all levels after 200 steps?

  # I guess we make a linked list of boards?
  # Make a rule that spawns a new board if a bug hits the outer edge
  #  or the inner edge.
  # Change the evaluation function to take other levels into account if needed.

  game = RecursiveBugs.new(input_rows.dup)
  200.times { game.step }
  bugs = game.num_bugs
  puts "part 2: after 200 steps, there are a total of #{bugs} bugs"
end

__END__
..###
##...
#...#
#.#.#
.#.#.
