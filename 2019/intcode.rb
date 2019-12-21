#!/usr/bin/env ruby

require 'pry'

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
              9 => {name: :change_relative_base,
                    size: 2},
              99 => {name: :halt,
                     size: 1}
            }.freeze

  attr_accessor :program, :ip, :instream, :outstream, :funcs, :relative_base
  
  def initialize(program, instream=$stdin, outstream=$stdout, debug=$stderr)
    if program.class == String
      @program = program.split(',').map(&:to_i)
    else
      @program = program
    end
    @instream = instream
    @outstream = outstream
    @dbgstream = debug
    @ip = 0
    @funcs = Funcs.new(self)
    @relative_base = 0
  end

  def debug(str)
    @dbgstream.puts("DEBUG: #{str}") unless @dbgstream.nil?
  end
  
  class Funcs
    attr_accessor :ins, :outs
    
    def initialize(machine)
      @machine = machine
      @ins = @machine.instream
      @outs = @machine.outstream
    end

    def _store(val, mem, addr)
      raise "stored a nil" if val.nil?
      mem[addr] = val
      nil
    end
    
    def add(mem, first, second, dest)
      _store(first.get + second.get, mem, dest.as_addr)
    end
    
    def mult(mem, first, second, dest)
      _store(first.get * second.get, mem, dest.as_addr)
    end

    def input(mem, dest)
      # print "> "
      inp = ins.gets.chomp.to_i
      @machine.debug "received input: #{inp}"
      _store(inp, mem, dest.as_addr)
    end

    def output(mem, first)
      outs.puts first.get
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
      _store( (first.get < second.get) ? 1 : 0, mem, result.as_addr)
    end
    
    def equals(mem, first, second, result)
      _store( (first.get == second.get) ? 1 : 0, mem, result.as_addr)
    end

    def change_relative_base(mem, new_base)
      @machine.relative_base += new_base.get
      nil
    end
  end

  def close_output
    @outstream.close_write
  end

  def run
    @ip = 0
    loop do
      new_ip = do_instr()
      if new_ip.nil?
        close_output
        return program
      else
        raise "invalid address: can't set ip to #{new_ip}" if new_ip >= program.size
        @ip = new_ip
      end
    end
  end

  private
  
  def do_instr
    op_value = @program[@ip]
    modes, opcode = parse_opvalue(op_value)
    raise "IP: #{ip} | invalid instruction #{opcode}" unless OPCODES.keys.include? opcode
    return nil if opcode == 99
    op = OPCODES[opcode]
    args = @program[@ip + 1, op[:size] - 1]
    # pad modes with zero
    modes = modes + [0] * (args.size - modes.size)
    parameter_args = modes.zip(args).map { |m,v| Parameter.new(m, v, @program, @relative_base) }
    debug "IP: #{@ip} | #{op[:name]} #{parameter_args.map { |x| x.get }}"
    begin
      new_ip = funcs.send(op[:name],
                          @program,
                          *parameter_args)
    rescue StandardError => e
      puts "intcode machine error, shit.  #{e.message}"
      puts "IP: #{@ip} | #{op[:name]} #{parameter_args.map { |x| x.get }}"
      parameter_args.each do |p|
        puts "param | mode: #{Parameter::VALID_MODES[p.mode]} value: #{p.value} relative: #{p.relative_base}"
      end
      binding.pry
    end
    if new_ip.nil?
      # just increment normally, instruction did not jump
      return @ip + op[:size]
    end
    return new_ip
  end

  def parse_opvalue(op)
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
  attr_accessor :mode, :value, :mem, :relative_base

  class BadModeException < Exception
  end

  VALID_MODES = {
    0 => :position,
    1 => :immediate,
    2 => :relative,
  }.freeze

  def initialize(mode, value, mem, relative_base=0)
    @mode = mode
    raise BadModeException unless VALID_MODES.keys.include? mode
    @value = value
    # mem will probably be modified by instructions.
    @mem = mem
    @relative_base = relative_base
  end

  def get
    # use the mode to dereference this parameter to its actual value
    return value if VALID_MODES[mode] == :immediate
    # positional parameter, inside mem:
    relative = 0
    if VALID_MODES[mode] == :relative
      relative = @relative_base
    end
    fetched = mem[value + relative]
    return 0 if fetched.nil?
    fetched
  end

  def as_addr
    return value + @relative_base if VALID_MODES[mode] == :relative
    value
  end
end


class WrappedIntcodeMachine
  attr_accessor :cpu

  def initialize(program)
    @program_saved = program.dup
    @program = nil
    @input = nil
    @output = nil
    @cpu = nil
    @cpu_thread = nil
    init_cpu
  end

  def method_missing(method, *args)
    if @cpu.respond_to?(method)
      @cpu.send(method, *args)
    else
      super
    end
  end

  def reset
    kill_thread
    init_cpu
  end

  def init_cpu
    @program = @program_saved.dup
    @input = IO.pipe
    @output = IO.pipe
    @cpu = IntcodeMachine.new(@program, @input[0], @output[1], nil)
    @cpu_thread = nil
  end

  def kill_thread
    @cpu_thread.kill unless @cpu_thread.nil?
  end

  def run
    @cpu_thread = Thread.new { @cpu.run }
  end

  def memory
    @cpu.program
  end

  def join
    @cpu_thread.join
  end

  def input
    @input[1]
  end

  def output
    @output[0]
  end
end


class AsciiIntcodeMachine < WrappedIntcodeMachine

  # Purpose: to be able to take in whole strings and
  # feed them one at a time to the intcode machine, encoded as ascii
  # numeric values (including newline as "10").

  def send_command(string)
    # convert each char of the command to ascii ord values,
    # and then send each one to the robot's input separately.
    if string[-1] != "\n"
      string << "\n"
    end
    string.chars.map(&:ord).map(&:to_s).each do |com|
      self.input.puts com
    end
    string
  end

  def readlines
    out_lines = []
    line = ""
    self.output.each_line do |ascii_number|
      char = ascii_number.to_i.chr
      if char == "\n"
        out_lines << line
        line = ""
      else
        line << char
      end
    end
    out_lines
  end
end
