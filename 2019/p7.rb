#!/usr/bin/env ruby

require_relative 'intcode'

def run_with_phases(program, phases, feedback=false)
  $stderr.puts("\nrun_with_phases #{phases}\n")
  num_procs = phases.size
  output_stream = -> (x) do
    if feedback
      (x+1) % num_procs
    else
      x+1
    end
  end
  # make an extra one in case we're not looped:
  iostreams = (0 .. num_procs).map { |x| IO.pipe }
  machines = (0 .. num_procs - 1).map do |x|
    # if feedback is true, then this will wrap the last output
    # to be the input of the first one
    os = output_stream.(x)
    IntcodeMachine.new(program.dup, iostreams[x][0], iostreams[os][1])
  end
  # seed phases in input
  phases.each_with_index { |p, i| iostreams[i][1].puts(p) }
  iostreams[0][1].puts(0)
  threads = []
  machines.each_with_index do |m, i|
    $stderr.puts "\nStarting machine #{i}..."
    threads << Thread.new { m.run }
  end
  threads.last.join
  #threads.each(&:join)
  answer = iostreams[output_stream.(num_procs-1)][0].gets.chomp.to_i
  $stderr.puts "\nlast machine output: #{answer}"
  answer
end

def run_all_phases(program)
  answers = (0..4).to_a.permutation(5).map { |arr| run_with_phases(program, arr) }
  answers.max
end

def run_feedback_phases(program)
  answers = (5..9).to_a.permutation(5).map { |arr| run_with_phases(program, arr, feedback=true) }
  answers.max
end

if __FILE__ == $0
  program = DATA.readlines[0].chomp.split(',').map(&:to_i).freeze
  puts "part 1: #{run_all_phases(program)}"

  puts "part 2: #{run_feedback_phases(program)}"
end

__END__
3,8,1001,8,10,8,105,1,0,0,21,34,47,72,93,110,191,272,353,434,99999,3,9,102,3,9,9,1001,9,3,9,4,9,99,3,9,102,4,9,9,1001,9,4,9,4,9,99,3,9,101,3,9,9,1002,9,3,9,1001,9,2,9,1002,9,2,9,101,4,9,9,4,9,99,3,9,1002,9,3,9,101,5,9,9,102,4,9,9,1001,9,4,9,4,9,99,3,9,101,3,9,9,102,4,9,9,1001,9,3,9,4,9,99,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,99,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,101,1,9,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,99
