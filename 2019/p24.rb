#!/usr/bin/env ruby

require 'pry'
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
    @size = size
    @rows = empty_board(size)
    @rows_next = empty_board(size)
    @center = size / 2
  end

  def empty_board(size=@size)
    board = []
    size.times do
      board << [false] * size
    end
    board
  end

  def set_board!(boolrows)
    @rows = []
    boolrows.each do |r|
      @rows << r.dup
    end
  end

  def set_loc(x, y, value)
    @rows[y][x] = value
  end

  def get_loc(x, y)
    raise "shit" if @rows.nil?
    raise "double shit (#{x}, #{y})" if @rows[y].nil?
    @rows[y][x]
  end

  def row(y)
    @rows[y]
  end

  def print
    puts ""
    (0..@size-1).each do |y|
      puts @rows[y].map { |x| x ? "#" : "." }*''
    end
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
    sides_any = @rows.reduce(false) do |sum, r|
      sum || r[0] || r[@size - 1]
    end
    sides_any
  end

  def needs_inner
    # true if any spots around center are 1
    return false unless self.inner.nil?
    return get_loc(@center - 1, @center) ||
           get_loc(@center + 1, @center) ||
           get_loc(@center, @center + 1) ||
           get_loc(@center, @center - 1)
  end

  def calc_next
    (0..@size-1).each do |y|
      (0..@size-1).each do |x|
        x_sum = 0
        y_sum = 0
        # check left and right
        if x == 0
          x_sum = outer_left + (get_loc(x+1, y) ? 1 : 0)
        elsif x == @size - 1
          x_sum = outer_right + (get_loc(x-1, y) ? 1 : 0)
        elsif x == @center - 1 && y == @center
          x_sum = inner_right + (get_loc(x-1, y) ? 1 : 0)
        elsif x == @center + 1 && y == @center
          x_sum = inner_left + (get_loc(x+1, y) ? 1 : 0)
        else
          x_sum = (get_loc(x-1, y) ? 1 : 0) + (get_loc(x+1, y) ? 1 : 0)
        end
        # check top and bottom
        if y == 0
          y_sum = outer_top + (get_loc(x, y+1) ? 1 : 0)
        elsif y == @size - 1
          y_sum = outer_bot + (get_loc(x, y-1) ? 1 : 0)
        elsif y == @center - 1 && x == @center
          y_sum = inner_down + (get_loc(x, y-1) ? 1 : 0)
        elsif y == @center + 1 && x == @center
          y_sum = inner_up + (get_loc(x, y+1) ? 1 : 0)
        else
          y_sum = (get_loc(x, y+1) ? 1 : 0) + (get_loc(x, y+1) ? 1 : 0)
        end
        # do something with x_sum, y_sum
        sum = x_sum + y_sum
        @rows_next[y][x] = false
        if get_loc(x, y) && sum == 1
          @rows_next[y][x] = true
        elsif !get_loc(x, y) && (sum == 1 || sum == 2)
          @rows_next[y][x] = true
        end
      end
    end
  end

  def set_next
    @rows = @rows_next
    @rows_next = empty_board
  end

  # some easy funcs for checking neighbour spots on inner and outer?
  # because if outer is nil, then outer_top should be false (empty)
  # Need to be able to evaluate the same even if the next thing over hasn't
  # been created yet.

  # when looking at outer, we always grab just one square
  def outer_top
    return 0 if outer.nil?
    # check bottom middle
    outer.get_loc(@center, @size - 1) ? 1 : 0
  end
  def outer_bot
    return 0 if outer.nil?
    # check top middle
    outer.get_loc(@center, 0) ? 1 : 0
  end
  def outer_left
    return 0 if outer.nil?
    # check right middle
    outer.get_loc(@size - 1, @center) ? 1 : 0
  end
  def outer_right
    return 0 if outer.nil?
    # check left middle
    outer.get_loc(0, @center) ? 1 : 0
  end

  # when looking at inner, we sum the whole side
  def inner_up
    # looking up at the bottom of the inner grid
    return 0 if inner.nil?
    # sum bottom edge
    (0..@size-1).map { |x| inner.get_loc(x, @size - 1) ? 1 : 0 }.sum
  end
  def inner_down
    return 0 if inner.nil?
    # sum top edge
    (0..@size-1).map { |x| inner.get_loc(x, 0) ? 1 : 0 }.sum
  end
  def inner_right
    return 0 if inner.nil?
    # sum left edge
    (0..@size-1).map { |y| inner.get_loc(0, y) ? 1 : 0 }.sum
  end
  def inner_left
    return 0 if inner.nil?
    # sum right edge
    (0..@size-1).map { |y| inner.get_loc(@size - 1, y) ? 1 : 0 }.sum
  end
end

class RecursiveBugs
  def initialize(string_rows)
    @init_rows = string_rows
    rows = @init_rows.map do |r|
      r.chars.map { |x| x == "#" }
    end
    @boards = []
    init_board = BugBoard.new
    init_board.set_board!(rows)
    init_board.print
    @boards << init_board
  end

  def step
    @boards.each { |b| make_inner(b) if b.needs_inner }
    @boards.each { |b| make_outer(b) if b.needs_outer }
    @boards.each { |b| b.calc_next }
    @boards.each { |b| b.set_next }
  end

  def print
    # print boards side by side
    (0..4).each do |y|
      combine_rows = @boards.map { |b| b.row(y).map { |x| x ? "#" : "." }*'' }*'  '
      puts combine_rows
    end
    puts ""
  end

  def make_board(dir, board)
    new_board = BugBoard.new
    board.send("#{dir}=", new_board)
    if dir == :inner
      new_board.outer = board
    else
      new_board.inner = board
    end
    @boards << board.send("#{dir}")
  end

  def make_inner(board)
    make_board(:inner, board)
  end

  def make_outer(board)
    make_board(:outer, board)
  end

  def num_bugs
    @boards.map { |b| b.num_bugs }.sum
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

  puts "starting part 2"
  puts ""
  game = RecursiveBugs.new(input_rows.dup)
  200.times { game.step; game.print }
  bugs = game.num_bugs
  puts "part 2: after 200 steps, there are a total of #{bugs} bugs"
end

__END__
..###
##...
#...#
#.#.#
.#.#.
