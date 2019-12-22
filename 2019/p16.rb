#!/usr/bin/env ruby

require 'pry' 
class FftCalc
  attr_reader :signal
  def initialize(input)
    # input is an array of single digits
    @input = input
    @signal = input.dup
    @base_pattern = [0, 1, 0, -1]
  end

  def apply(n)
    #binding.pry
    n.times do
      output = Array.new(@signal.size, 0)
      (0 .. @signal.size-1).each do |output_idx|
        output[output_idx] = product(divider: output_idx+1)
      end
      @signal = output
    end
  end

  def product(divider:)
    # divider divides the frequency, so we repeat each element of the
    # base pattern that many times.
    pattern = @base_pattern.flat_map { |x| [x]*divider }.rotate!(1)
    @signal.zip(pattern.cycle).map { |a,b| (a*b) }.sum.abs % 10
  end

  def output
    @signal*''
  end
end


if __FILE__ == $0
  signal = DATA.readlines[0].chomp.chars.map(&:to_i)
  # input is a signal, with single digits
  # match up the digits of the pattern with digits of the signal
  #  (repeating the pattern if necessary), and multiply each.
  # sum the whole result (like a dot product), except you only
  # keep the 1s digit of each. x % 10

  # to get each element of the output array, you repeat each
  # element of the window to make a double-size window, and use that to
  # do the multiply and add step against the whole input.

  # before applying the pattern, chop off the first element (like indexed from 1?)
  # After an output of a phase is computed in full, it's used as the next input phase.
  base_pattern = [0, 1, 0, -1]
  calc = FftCalc.new(signal)
  calc.apply(100)
  answer = calc.output[0,8]
  puts "part 1: answer is #{answer}"

  # part 2 - input is repeated 10000 times, "message" has an offset way into the output based
  # on first 7 chars being the offset. apply 100 times, find offset message.
  #
  # The trick was that when you need the offset numbers that are at a position indexed by the
  # first 7 digits, it means that the numbers you need are past the halfway point in the
  # 650*10000 element array.
  #
  # Because you're past the halfway mark, the pattern for your position N will be N zeroes, and then 1s
  # to the end of the array from there. That means the value is just the sum of everything from there to
  # the end. Then when you repeat the calculation another round, it's the same.
  # So you can just start at the back end and compute the sum down to your position N, and then repeat
  # that procedure starting from the end again. You get to compute your offset numbers super simply without
  # any inputs from earlier numbers.

  offset = (signal[0,7]*'').to_i
  puts "offset = #{offset}"
  bigsignal = signal*10000
  mysignal = bigsignal[offset .. -1]
  100.times do |time|
    puts "#{time}"
    (mysignal.size - 2).downto(0) do |i|
      mysignal[i] = (mysignal[i] + mysignal[i+1]) % 10
    end
  end
  answer = mysignal[0, 8]*''

  puts "part 2: answer is #{answer}"
end

__END__
59756772370948995765943195844952640015210703313486295362653878290009098923609769261473534009395188480864325959786470084762607666312503091505466258796062230652769633818282653497853018108281567627899722548602257463608530331299936274116326038606007040084159138769832784921878333830514041948066594667152593945159170816779820264758715101494739244533095696039336070510975612190417391067896410262310835830006544632083421447385542256916141256383813360662952845638955872442636455511906111157861890394133454959320174572270568292972621253460895625862616228998147301670850340831993043617316938748361984714845874270986989103792418940945322846146634931990046966552
