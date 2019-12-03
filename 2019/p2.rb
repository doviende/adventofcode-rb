#!/usr/bin/env ruby

OPCODES = { 1 => {name: :add,
                size: 4},
            2 => {name: :mult,
                size: 4},
            99 => {name: :halt,
                 size: 1}
          }.freeze

class Funcs
  class << self
    def add(mem, first, second, dest)
      mem[dest] = mem[first] + mem[second]
    end

    def mult(mem, first, second, dest)
      mem[dest] = mem[first] * mem[second]
    end
  end
end

def run(input)
  ip = 0
  loop do
    incr = do_instr(ip, input)
    if incr == 0
      return input
    else
      ip += incr
    end
  end
end

def do_instr(ip, input)
  op_num = input[ip]
  raise "invalid instruction" unless OPCODES.keys.include? op_num
  return 0 if op_num == 99
  op = OPCODES[op_num]
  args = input[ip + 1, op[:size] - 1]
  # puts ">> IP: #{ip}   OP: #{op[:name]}  args: #{args}"
  Funcs.send(op[:name],
             input,
             *args)
  return op[:size]
end

#part 2
# need to run the program on a whole bunch of pairs of numbers that go at 1 and 2
# find the inputs that give the output 19690720

def part2(program)
  special = 19690720
  (0..99).to_a.repeated_permutation(2).each do |noun, verb|
    input = program.dup
    input[1] = noun
    input[2] = verb

    output = run(input)
    puts "noun = #{noun}, verb = #{verb}, output = #{output[0]}"
    if output[0] == special
      return [noun, verb]
    end
  end
  puts "fuck"
  return [-1, -1]
end

if __FILE__ == $0
  program = DATA.readlines[0].split(',').map(&:to_i)
  program[1] = 12
  program[2] = 2
  program.freeze
  output = run(program.dup)
  puts "part 1: position 0 result is: #{output[0]}"

  noun, verb = part2(program)
  puts "part 2: 100 * #{noun} + #{verb} = #{100 * noun + verb}"
end

__END__
1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,13,1,19,1,19,10,23,2,10,23,27,1,27,6,31,1,13,31,35,1,13,35,39,1,39,10,43,2,43,13,47,1,47,9,51,2,51,13,55,1,5,55,59,2,59,9,63,1,13,63,67,2,13,67,71,1,71,5,75,2,75,13,79,1,79,6,83,1,83,5,87,2,87,6,91,1,5,91,95,1,95,13,99,2,99,6,103,1,5,103,107,1,107,9,111,2,6,111,115,1,5,115,119,1,119,2,123,1,6,123,0,99,2,14,0,0
