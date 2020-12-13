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
    @base = @offset_input[0].to_i
    puts "input: #{offset_input}"
  end

  def remainder_for(n)
    (n - @offsets[n]) % n
  end

  def find_multiplier_for(n, previous_mult = 0, priors = [])
    # multiply @base by successive ints mod n until we hit remainder_for(n)
    puts "finding multiplier for #{n}:"
    extra = priors.reduce(:lcm) || 1
    multiplier = nil
    (1..).each do |m|
      multiplier = previous_mult + m*extra
      remainder = (@base * multiplier) % n
      puts "#{n} with mult #{multiplier}: remainder is #{remainder}, searching for #{remainder_for(n)}"
      break if remainder == remainder_for(n)
    end
    multiplier
  end

  def find_number
    mult = 0
    priors = []
    @offsets.keys.reject { |k| k==@base }.each do |k|
      mult = find_multiplier_for(k, mult, priors)
      priors.push k
    end
    answer = @base * mult
    @offsets.keys.each do |k|
      puts "#{k} - #{answer} % #{k} = #{k - (answer % k)}"
    end
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
  #
  # Doh! ok, that didn't quite work. the problem is that when 23*f1 hits 28 mod 41, once you multiply it by f2,
  # it no longer does. so f2 can't be a simple multiplier, it has to be something that is also invisible to mod 41,
  # ie it has to be 41, 82, 123, etc. And then when you go to f3, it has to be m*41*449. Maybe f1 has to be a multiple of
  # the LCM of the other IDs?
  #
  # example problem: "17, x, 13, 19".  need 17*f1*f2 such that 17*(m1*19) = 11 mod 13, and 17*(m2*13) = 16 mod 19,
  # If 17*f1 = 11 mod 13, there are several f1s that fit this. We need one that also matches the other conditions
  # like 17*f1 = 16 mod 19. If we start with the least f1 that satisfies, we then want to make it bigger somehow while
  # still preserving its value mod 13...so we can ...add 13 to it? So f1=6 is the lowest number such that 17*f1 = 11 mod 13.
  # so what about 13 + 6 = 19? 17*19 = 11 mod 13 as well, but it is 0 mod 19. try again. 19+13 = 32. keep adding 13 until
  # it works for 19 as well. so 6 + 13n = 11 + 19m. in this case, n = 15 and m = 10
  #
  # What do we do when there are more numbers? it was easy to just add 13 a couple times and get to the right value mod 19,
  # but then what's the next one? i guess we add LCM(13,19) over and over until it matches.
  #
  # ok, summary again.
  # * the first ID is the base.
  # * we take the second ID, and find the simples f1 that gets the right remainder.
  # * next we want to bring in the 3rd ID, so we take f1 and continually add the second ID until it gets the right
  #   remainder for the 3rd ID
  # * to factor in the 4th ID, we then take the new multiplier and continually add LCM(2nd, 3rd) until it matches.

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
