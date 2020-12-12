#!/usr/bin/env ruby
require "active_support/core_ext/object/blank"
require "set"

# part 1
def score(list)
  # score is the number of 1-differences (starting from 0) times
  # the number of 3-differences, with one more 3-difference on the end.
  # list is sorted.
  list = [0] + list + [list.last + 3]
  onediffs = 0
  threediffs = 0
  list.each_cons(2) do |a, b|
    diff = b - a
    if diff == 1
      onediffs += 1
    elsif diff == 3
      threediffs += 1
    end
  end
  onediffs * threediffs
end

# part 2
# We have to count the number of valid arrangements of the numbers
# such that they go from 0 to (max + 3) with each step in between
# having a difference of either +1, +2, +3.
  # notes:
  # * there's always a solution with every element included.
  # * sometimes each individual element can be taken out
  # * after taking an element out of the list, we probably evaluate the remaining
  #   ones to see if it's still valid.
  # * make a search tree where we want to see how many nodes we can take out until
  #   it becomes invalid,
  # * and then nodes are equivalent if they have the same set of unique elements
  #   that had to be removed to get to that state.
  # * states are addressed by the things removed to get to it.
  # * if a certain number can't be removed in the current set, then it also
  #   can't be removed in any subset.
  # * need some sort of way to save sub-solutions
  # * how do we generate the search nodes? breadth-first testing which can be removed?
  # * take parent node's list of nodes that can be removed and only check if they
  #   can be removed from this node.
  # * generate the list of new nodes to work on, and skip any of them that have already been done.
#
# New Notes:
# ok, tried searching in a naive way, and it works for the sample answers, but
# the actual input is just too huge to do naively.
# * key insight: whenever 2 neighbours are distance 3, both of those
#   are non-removable.
# * if two non-removable ones (due to an empty 3-gap elsewhere) have some
#   other potentially removable ones in between, but the non-removable ones
#   are 3 away, then everything in between is unconditionally removable
# * if everything potentially removable is unconditionally removable, then
#   the answer is 2^n where in is the unconditionally removable (UR) elements.
# * if there's a filled gap of size 4+ between some NRs, then the ones in betweenn
#   are Conditionally Removable (CR), and some of them will always have to be kept
#   in order to bridge the gap.
# * so the answer should be 2^UR + f(CR), and maybe we can perform search on the CRs.
# * the CRs convert into a smaller sub-problem if we keep the right-hand-side, which
#   acts like the previous @last element (is followed by an invisible 3-gap)
# * the zero part will have to be changed, perhaps substituted by the previous NR.

class JoltOrderer
  attr_reader :list

  def initialize(list, first = 0)
    @list = SortedSet.new(list)
    @last = list.sort.last
    @first = first
    @states = nil
    @queue = nil
    @precalculated = 0
  end

  def num_arrangements
    # generate first removals
    generate_new_nodes(nil)

    loop do
      break if queue.empty?

      nextcheck = queue.shift
      next if states[nextcheck]

      # puts "considering removals: #{nextcheck.total_removed}"
      if valid_removal? nextcheck
        states[nextcheck] = 1
        generate_new_nodes(nextcheck)
      else
        states[nextcheck] = 0
      end
    end
    states.values.sum + 1 # nothing removed is a valid state
  end

  def generate_new_nodes(remstate)
    # remstate contains a RemovalState that has the items that have been removed so far.
    # We need to generate a search node that attempts to remove any other element in
    # the list that is not in remstate
    if remstate.nil?
      todo = @list
    else
      todo = @list - remstate.total_removed
    end
    todo.each do |item|
      queue.push(RemovalState.new(item, remstate))
    end
  end

  def valid_removal?(remstate)
    return false if remstate.removed == @last

    checklist = [@first] + (@list - remstate.total_removed).to_a
    checklist.each_cons(2) do |a,b|
      return false unless [1,2,3].include? (b - a)
    end

    true
  end

  def states
    @states ||= {}
  end

  def queue
    @queue ||= []
  end
end

class RemovalState
  attr_reader :removed
  attr_reader :total_removed

  def initialize(removed, parent)
    @removed = removed
    @parent = parent
    if parent.nil?
      @total_removed = [removed].compact.to_set
    else
      @total_removed = parent.total_removed.dup.add(removed)
    end
  end

  def hash
    total_removed.hash
  end

  def ==(other)
    self.class === other and
      other.total_removed == total_removed
  end

  alias eql? ==
end


class Part2RedoOmg
  # JoltOrderer was too slow, need to redo it with more math, less search.
  # a) some items are "non-removable" (NR) because they are 3 apart.
  # b) every time the nearest 2 NRs are also 3 apart, everything in between
  #    is "unconditionally removable" (UR), and you can just count them all
  #    up and the answer is 2 ** UR.size.
  # c) the only tricky part is if there are "conditionally removable" (CR)
  #    elements in a space where the nearest NRs are more than 3 apart, because
  #    every arrangement has to leave at least one of them to bridge the gap.
  #    So a space of 6 could be spanned by 1 number making 2 3-gaps, or 2 numbers
  #    making 3 2-gaps, etc. depends on the values present.
  # d) We can take a shortcut if the gap sizes are at most 4, because it's easy
  #    to count if we only have to leave 1 in as a bridge.

  class AlgorithmFailError < StandardError; end

  def initialize(lines)
    @list = [0] + lines + [lines.last + 3] # lines is sorted and to_i
    @types = nil
    @conditional_group_sizes = []
  end

  def types
    @types ||= {}
  end

  def find_nonremovables
    types[0] = :nr # by problem definition
    @list.each_cons(2) do |a, b|
      if (b - a) == 3
        types[a] = :nr
        types[b] = :nr
      end
    end
  end

  def score
    process_list
    ur = types.values.count { |i| i == :ur }
    conditional_score * (2 ** ur)
  end

  def process_list
    find_nonremovables
    process_removables
  end

  def process_removables
    # have a current counter and a search_counter to move ahead.
    # move the search counter ahead until the next NR, while current_counter
    # is on the current NR. if (search - current) is <= 3, everything in between
    # is UR and can just be added to types as such.
    # If (search - current) is 4, then everything in between is CR.
    # If (search - current) is > 4, then the easy counting method in conditional_score
    # won't work and we fail.

    current = 0
    search = 0
    loop do
      search += 1
      break if search >= @list.size
      next unless types[@list[search]] == :nr

      # mark things in between current and search
      if (@list[search] - @list[current] <= 3)
        type = :ur
      elsif (@list[search] - @list[current] == 4)
        type = :cr
      else
        raise AlgorithmFailError
      end
      between = @list[(current+1)..(search-1)]
      puts "#{between.size} of #{type}: #{between}"
      between.each do |item|
        types[item] = type
      end
      if type == :cr
        @conditional_group_sizes.push(between.size)
      end
      current = search
    end
  end

  def conditional_score
    # approximation, only works if there are no conditional gaps bigger than 4,
    # so that we can leave any single element between.
    # We must choose to leave at least 1 in: N ways to choose 1.
    # We could choose 2: N choose 2 = 1 (if 2 elements), or 3 if 3 elements
    # or we could choose to leave all in: 1
    @conditional_group_sizes.reduce(1) do |accum, size|
      if size == 1
        accum
      elsif size == 2
        accum * (2 + 1)
      elsif size == 3
        accum * (3 + 3 + 1)
      end
    end
  end
end

if __FILE__ == $0
  lines = DATA.readlines(chomp: true).map(&:to_i).sort
  puts lines
  part1 = score(lines)
  puts "part 1 score is #{part1}"

  part2 = Part2RedoOmg.new(lines).score
  puts "part 2: the number of unique arrangements is #{part2}"
end

__END__
17
110
146
144
70
57
124
121
134
12
135
120
19
92
6
103
46
56
93
65
14
31
63
41
131
60
73
83
71
37
85
79
13
7
109
24
94
2
30
3
27
77
91
106
123
128
35
26
112
55
97
21
100
88
113
117
25
82
129
66
11
116
64
78
38
99
130
84
98
72
50
36
54
8
34
20
127
1
137
143
76
69
111
136
53
43
140
145
49
122
18
42
