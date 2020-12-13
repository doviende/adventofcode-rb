#!/usr/bin/env ruby
require "active_support/core_ext/object/blank"

class MultFinder
  def initialize(offset_input)
    @offset_input = offset_input.split(",")
    @offsets = {}
    @offset_input.each.with_index do |n, i|
      next if n == "x"
      @offsets[n.to_i] = i
    end
  end

  def remainder_for(n)
    (n - @offsets[n]) % n
  end

  def find_multiplier_for(n)
    # multiply 23 by successive ints mod n until we hit remainder_for(n)
    puts "finding multiplier for #{n}:"
    multiplier = nil
    (1..).each do |m|

      multiplier = m
      remainder = (23*m) % n
      puts "#{n} with mult #{m}: remainder is #{remainder}, searching for #{remainder_for(n)}"
      break if (23*m) % n == remainder_for(n)
    end
    multiplier
  end

  def find_number
    mults = @offsets.keys.map { |k| find_multiplier_for(k) }
    answer = mults.reduce(:*)
    puts "mults: #{mults} --> #{answer}"
    answer
  end
end


if __FILE__ == $0
  lines = DATA.readlines(chomp: true)

  #part 1 - find the earliest bus that comes after the timestamp.
  # --> need the remainder of dividing the timestamp by each of the IDs,
  # and then add one more X and see how far it goes past the timestamp.

  first_minute = lines[0].to_i
  bus_ids = lines[1].split(",").reject { |i| i == "x" }.map(&:to_i)
  remainder_plus = bus_ids.map { |x| [x - (first_minute % x), x] }.sort_by { |a, b| a }.first
  puts "first bus to arrive is #{remainder_plus[1]}, and score is #{remainder_plus.reduce(:*)}"

  # part 2 - need to find a time that matches the pattern, such that the listed buses arrive at the listed minutes.
  # so (t % 23) = 0, (41 - t % 41) = 13, (449 - t % 449) = 23, etc.
  # ==> t % 41 = 41 - 13 = 28 ==> t - 28 = a*41
  # ==> t % 449 = 449 - 23 = 426 ==> t - 426 = b*449
  # ==> t = a*41 + 28 = b*449 + 426 = c*23
  # ==> c = (...
  #
  # since 23|t, then what's the relationship of 23 to 41 and the other numbers, since we know that t will be
  # 28 more than a multiple of 41. so if we're multiplying 23 by something in mod 41 until we get to 28. So let's
  # say we find a number f1 such that 23*f1 = 28 (mod 41). i think we now know that t is divisible by 23*f1.
  # now we do the same for 449, where we want 23*f2 = 426 (mod 449), and then t is divisible by 23*f1*f2

  # steps
  # 1) find the offset of each ID number.
  # 2) find the remainder associated with each ID, using t % ID = (ID - ID_index)
  # 3) 23 will be called the "base". for each ID, multiply the base by successive ints mod ID
  #    until we reach the right remainder value. this multiplier will be the "f" value for that ID.
  # 4) find all the f values.
  # 5) t = 23 * f1 * f2 * f3 ...

  finder = MultFinder.new(lines[1])
  puts "part 2: the matching number is #{finder.find_number}"
end

__END__
1008832
23,x,x,x,x,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,x,449,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,13,19,x,x,x,x,x,x,x,x,x,29,x,991,x,x,x,x,x,37,x,x,x,x,x,x,x,x,x,x,17
