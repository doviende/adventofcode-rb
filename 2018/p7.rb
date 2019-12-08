#!/usr/bin/env ruby

class Graph
  attr_accessor :all_nodes, :root

  def initialize(list_of_connections)
    # list of connections is a whole bunch of pairs of [parent, child]
    # possibly many for the same parent.
    @all_nodes = {}
    list_of_connections.each do |parent, child|
      node = @all_nodes.fetch(parent, GraphNode.new(parent))
      @all_nodes[parent] ||= node
      child_node = @all_nodes.fetch(child, GraphNode.new(child))
      @all_nodes[child] ||= child_node
      node.add_child(child_node)
    end
  end

  def do_tasks
    order_list = []
    ready_queue = @all_nodes.sort.map { |k,v| v.done = false; v }.select { |v| v.ready? }
    # grab a node from the top of the ready queue
    # add its children to the ready queue if all their parents are done already
    # sort, and then take the next one off the top
    $stderr.puts "all nodes: #{@all_nodes.map { |k,v| v.id }.sort*''}"
    loop do
      $stderr.puts "options: #{ready_queue.map{|n| n.id}*''}"
      next_node = ready_queue.shift
      order_list.push(next_node.id)
      next_node.done = true
      $stderr.puts "job #{next_node.id} done"
      next_node.children.each do |n|
        if n.ready?
          ready_queue.push n
        end
      end
      break if ready_queue.empty?
      ready_queue = ready_queue.sort_by { |n| n.id }
    end
    return order_list*''
  end
end

class GraphNode
  attr_accessor :id, :children, :parents, :done

  def initialize(id)
    @id = id
    @children = []
    @parents = []
    @done = false
  end

  def done?
    @done
  end

  def ready?
    @parents.empty? || @parents.all? { |p| p.done? }
  end
  
  def add_child(child_node)
    child_node.parents << self
    @children << child_node
  end
end

if __FILE__ == $0
  step_orders = DATA.readlines.map { |line| line.match(/Step (.).*before step (.)/).captures }
  graph = Graph.new(step_orders)
  order = graph.do_tasks
  puts "part 1: #{order}"
end

__END__
Step G must be finished before step T can begin.
Step L must be finished before step V can begin.
Step D must be finished before step P can begin.
Step J must be finished before step K can begin.
Step N must be finished before step B can begin.
Step K must be finished before step W can begin.
Step T must be finished before step I can begin.
Step F must be finished before step E can begin.
Step P must be finished before step O can begin.
Step X must be finished before step I can begin.
Step M must be finished before step S can begin.
Step Y must be finished before step O can begin.
Step I must be finished before step Z can begin.
Step V must be finished before step Z can begin.
Step Q must be finished before step Z can begin.
Step H must be finished before step C can begin.
Step R must be finished before step Z can begin.
Step U must be finished before step S can begin.
Step E must be finished before step Z can begin.
Step O must be finished before step W can begin.
Step Z must be finished before step S can begin.
Step S must be finished before step C can begin.
Step W must be finished before step B can begin.
Step A must be finished before step B can begin.
Step C must be finished before step B can begin.
Step L must be finished before step P can begin.
Step J must be finished before step V can begin.
Step E must be finished before step W can begin.
Step Z must be finished before step W can begin.
Step W must be finished before step C can begin.
Step S must be finished before step W can begin.
Step Q must be finished before step S can begin.
Step O must be finished before step B can begin.
Step R must be finished before step W can begin.
Step D must be finished before step H can begin.
Step E must be finished before step O can begin.
Step Y must be finished before step H can begin.
Step V must be finished before step O can begin.
Step O must be finished before step S can begin.
Step X must be finished before step V can begin.
Step R must be finished before step E can begin.
Step S must be finished before step A can begin.
Step K must be finished before step Y can begin.
Step V must be finished before step W can begin.
Step U must be finished before step W can begin.
Step H must be finished before step R can begin.
Step P must be finished before step I can begin.
Step E must be finished before step C can begin.
Step H must be finished before step Z can begin.
Step N must be finished before step V can begin.
Step N must be finished before step W can begin.
Step A must be finished before step C can begin.
Step V must be finished before step E can begin.
Step N must be finished before step Q can begin.
Step Y must be finished before step V can begin.
Step R must be finished before step O can begin.
Step R must be finished before step C can begin.
Step L must be finished before step S can begin.
Step V must be finished before step R can begin.
Step X must be finished before step R can begin.
Step Z must be finished before step A can begin.
Step O must be finished before step Z can begin.
Step U must be finished before step C can begin.
Step X must be finished before step W can begin.
Step K must be finished before step O can begin.
Step O must be finished before step A can begin.
Step K must be finished before step T can begin.
Step N must be finished before step O can begin.
Step X must be finished before step C can begin.
Step Z must be finished before step C can begin.
Step N must be finished before step X can begin.
Step T must be finished before step A can begin.
Step D must be finished before step O can begin.
Step M must be finished before step Q can begin.
Step D must be finished before step C can begin.
Step U must be finished before step E can begin.
Step N must be finished before step H can begin.
Step I must be finished before step U can begin.
Step N must be finished before step A can begin.
Step M must be finished before step E can begin.
Step M must be finished before step V can begin.
Step P must be finished before step B can begin.
Step K must be finished before step X can begin.
Step N must be finished before step S can begin.
Step S must be finished before step B can begin.
Step Y must be finished before step W can begin.
Step K must be finished before step Q can begin.
Step V must be finished before step S can begin.
Step E must be finished before step S can begin.
Step N must be finished before step Z can begin.
Step P must be finished before step A can begin.
Step T must be finished before step V can begin.
Step L must be finished before step D can begin.
Step I must be finished before step C can begin.
Step Q must be finished before step E can begin.
Step Y must be finished before step U can begin.
Step J must be finished before step I can begin.
Step P must be finished before step H can begin.
Step T must be finished before step M can begin.
Step T must be finished before step E can begin.
Step D must be finished before step F can begin.
