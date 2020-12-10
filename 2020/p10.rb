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
class JoltOrderer
  attr_reader :list

  def initialize(list)
    @list = SortedSet.new(list)
    @last = list.sort.last
    @states = nil
    @queue = nil
  end

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

    checklist = [0] + (@list - remstate.total_removed).to_a
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


if __FILE__ == $0
  lines = DATA.readlines(chomp: true).map(&:to_i).sort
  part1 = score(lines)
  puts "part 1 score is #{part1}"

  orderer = JoltOrderer.new(lines)
  part2 = orderer.num_arrangements
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
