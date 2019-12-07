#!/usr/bin/env ruby

class IntcodeMachine
  # size is for opcode plus args, to advance the instruction pointer
  OPCODES = { 1 => {name: :add,
                    size: 4},
              2 => {name: :mult,
                    size: 4},
              3 => {name: :input,
                    size: 2},
              4 => {name: :output,
                    size: 2},
              5 => {name: :jump_if_true,
                    size: 3},
              6 => {name: :jump_if_false,
                    size: 3},
              7 => {name: :less_than,
                    size: 4},
              8 => {name: :equals,
                    size: 4},
              99 => {name: :halt,
                     size: 1}
            }.freeze

  attr_accessors :program, :ip, :instream, :outstream, :funcs
  
  def initialize(program, instream=$stdin, outstream=$stdout)
    @program = program
    @instream = instream
    @outstream = outstream
    @ip = 0
    @funcs = Funcs.new(@instream, @outstream)
  end
  
  class Funcs
    attr_accessor :in, :out
    
    def initialize(in_io, out_io)
      @in = in_io
      @out = out_io
    end
    
    def add(mem, first, second, dest)
      mem[dest.value] = first.get + second.get
      nil
    end
    
    def mult(mem, first, second, dest)
      mem[dest.value] = first.get * second.get
      nil
    end

    def input(mem, dest)
      print "> "
      mem[dest.value] = in.gets.chomp.to_i
      puts
      nil
    end

    def output(mem, first)
      out.puts first.get
      nil
    end

    def jump_if_true(mem, cmp, dest)
      if cmp.get != 0
        return dest.get
      end
      nil
    end

    def jump_if_false(mem, cmp, dest)
      if cmp.get == 0
        return dest.get
      end
      nil
    end

    def less_than(mem, first, second, result)
      mem[result.value] = (first.get < second.get) ? 1 : 0
      nil
    end
    
    def equals(mem, first, second, result)
      mem[result.value] = (first.get == second.get) ? 1 : 0
      nil
    end
  end

  def run
    ip = 0
    loop do
      new_ip = do_instr()
      if new_ip.nil?
        return program
      else
        raise "invalid address: can't set ip to #{new_ip}" if new_ip >= program.size
        ip = new_ip
      end
    end
  end

  private
  
  def do_instr
    op_value = program[ip]
    modes, opcode = parse_opvalue(op_value)
    raise "IP: #{ip} | invalid instruction #{opcode}" unless OPCODES.keys.include? opcode
    return nil if opcode == 99
    op = OPCODES[opcode]
    args = program[ip + 1, op[:size] - 1]
    # pad modes with zero
    modes = modes + [0] * (args.size - modes.size)
    parameter_args = modes.zip(args).map { |m,v| Parameter.new(m, v, program) }
    $stderr.puts "DEBUG: IP: #{ip} | #{op[:name]} #{parameter_args.map { |x| x.get }}"
    new_ip = funcs.send(op[:name],
                        program,
                        *parameter_args)
    if new_ip.nil?
      # just increment normally, instruction did not jump
      return ip + op[:size]
    end
    return new_ip
  end

  def self.parse_opvalue(op)
    # given an integer op, separate it into parameter modes and an opcode
    # return a list of the parameter modes and the op code
    dig = op.digits.reverse
    opcode = (dig.pop(2) * '').to_i
    modes = dig.reverse
    return [modes, opcode]
  end
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
