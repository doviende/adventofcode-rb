#!/usr/bin/env ruby
require 'pry'

OPCODES = { 1 => {name: :add,
                  size: 4},
            2 => {name: :mult,
                  size: 4},
            3 => {name: :input,
                  size: 2},
            4 => {name: :output,
                  size: 2},
            99 => {name: :halt,
                 size: 1}
          }.freeze

class Funcs
  class << self
    def add(mem, first, second, dest)
      mem[dest.value] = first.get + second.get
    end

    def mult(mem, first, second, dest)
      mem[dest.value] = first.get * second.get
    end

    def input(mem, dest)
      print "> "
      mem[dest.value] = gets.chomp.to_i
    end

    def output(mem, first)
      puts first.get
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
  op_value = input[ip]
  modes, opcode = parse_opvalue(op_value)
  raise "IP: #{ip} | invalid instruction #{opcode}" unless OPCODES.keys.include? opcode
  return 0 if opcode == 99
  op = OPCODES[opcode]
  args = input[ip + 1, op[:size] - 1]
  # pad modes with zero
  modes = modes + [0] * (args.size - modes.size)
  parameter_args = modes.zip(args).map { |m,v| Parameter.new(m, v, input) }
  Funcs.send(op[:name],
             input,
             *parameter_args)
  return op[:size]
end

def parse_opvalue(op)
  # given an integer op, separate it into parameter modes and an opcode
  # return a list of the parameter modes and the op code
  dig = op.digits.reverse
  opcode = (dig.pop(2) * '').to_i
  modes = dig.reverse
  return [modes, opcode]
end

class Parameter
  # each Parameter has a mode and a value.
  attr_accessor :mode, :value, :mem

  class BadModeException < Exception
  end

  VALID_MODES = {
    0 => :position,
    1 => :immediate,
  }

  def initialize(mode, value, mem)
    self.mode = mode
    raise BadModeException unless VALID_MODES.keys.include? mode
    self.value = value
    # mem will probably be modified by instructions.
    self.mem = mem
  end

  def get
    # use the mode to dereference this parameter to its actual value
    return value if VALID_MODES[mode] == :immediate
    # positional parameter, inside mem:
    mem[value]
  end
end

if __FILE__ == $0
  program = DATA.readlines[0].split(',').map(&:to_i).freeze
  output = run(program.dup)
end

__END__
3,225,1,225,6,6,1100,1,238,225,104,0,1102,67,92,225,1101,14,84,225,1002,217,69,224,101,-5175,224,224,4,224,102,8,223,223,101,2,224,224,1,224,223,223,1,214,95,224,101,-127,224,224,4,224,102,8,223,223,101,3,224,224,1,223,224,223,1101,8,41,225,2,17,91,224,1001,224,-518,224,4,224,1002,223,8,223,101,2,224,224,1,223,224,223,1101,37,27,225,1101,61,11,225,101,44,66,224,101,-85,224,224,4,224,1002,223,8,223,101,6,224,224,1,224,223,223,1102,7,32,224,101,-224,224,224,4,224,102,8,223,223,1001,224,6,224,1,224,223,223,1001,14,82,224,101,-174,224,224,4,224,102,8,223,223,101,7,224,224,1,223,224,223,102,65,210,224,101,-5525,224,224,4,224,102,8,223,223,101,3,224,224,1,224,223,223,1101,81,9,224,101,-90,224,224,4,224,102,8,223,223,1001,224,3,224,1,224,223,223,1101,71,85,225,1102,61,66,225,1102,75,53,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,8,226,226,224,102,2,223,223,1005,224,329,1001,223,1,223,1108,677,677,224,1002,223,2,223,1006,224,344,101,1,223,223,1007,226,677,224,102,2,223,223,1005,224,359,101,1,223,223,1007,677,677,224,1002,223,2,223,1006,224,374,101,1,223,223,1108,677,226,224,1002,223,2,223,1005,224,389,1001,223,1,223,108,226,677,224,102,2,223,223,1006,224,404,101,1,223,223,1108,226,677,224,102,2,223,223,1005,224,419,101,1,223,223,1008,677,677,224,102,2,223,223,1005,224,434,101,1,223,223,7,677,226,224,1002,223,2,223,1005,224,449,101,1,223,223,1008,226,226,224,102,2,223,223,1005,224,464,1001,223,1,223,107,226,677,224,1002,223,2,223,1006,224,479,1001,223,1,223,107,677,677,224,102,2,223,223,1005,224,494,1001,223,1,223,1008,226,677,224,102,2,223,223,1006,224,509,1001,223,1,223,1107,677,226,224,102,2,223,223,1005,224,524,101,1,223,223,1007,226,226,224,1002,223,2,223,1006,224,539,1001,223,1,223,107,226,226,224,102,2,223,223,1006,224,554,101,1,223,223,108,677,677,224,1002,223,2,223,1006,224,569,1001,223,1,223,7,226,677,224,102,2,223,223,1006,224,584,1001,223,1,223,8,677,226,224,102,2,223,223,1005,224,599,101,1,223,223,1107,677,677,224,1002,223,2,223,1005,224,614,101,1,223,223,8,226,677,224,102,2,223,223,1005,224,629,1001,223,1,223,7,226,226,224,1002,223,2,223,1006,224,644,1001,223,1,223,108,226,226,224,1002,223,2,223,1006,224,659,101,1,223,223,1107,226,677,224,1002,223,2,223,1006,224,674,101,1,223,223,4,223,99,226

