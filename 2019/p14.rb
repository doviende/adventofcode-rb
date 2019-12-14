#!/usr/bin/env ruby

require 'pry'
# have ORE, need to produce FUEL. Find out how much ORE you need
# to produce 1 unit of FUEL.

# plan:
# - make a stack, push [FUEL, 1]
# - find a rule that produces fuel,
# - pop FUEL, push precursors to FUEL
# - repeat
# For some ingredient ABC, if we have [ABC, 17] and a rule
# that says 1 FOO => 11 ABC, then we need to do 17 // 11 = 2
# and make 22 ABC with 5 extra
# Then we take the [ABC, 17] out because it's satisfied,
# and push [FOO, 2] in its place.
# Because every product (ABC in this case) has a unique rule that
# produces it, we can always safely pop it and replace it, being
# careful to save the excess in case another rule requires ABC.
# We don't want to apply the same rule again needlessly if we have
# excess available to cover it.

# We can't divide down a rule into smaller bits, but we can always
# multiply it up to produce more.

# if the amount on the stack is less than required for production by a
# rule, then we either borrow some from stock to make up the difference,
# or we multiply the rule.



class Rule
  attr_accessor :product, :amount, :reagents

  def initialize(ruletext)
    # example ruletext: "114 ORE => 4 BHXH"
    precursors, resultant = ruletext.split(' => ')
    @product, @amount = to_reagent(resultant).to_a
    @reagents = to_reagent_list(precursors)
  end

  def to_s
    "<Rule: #{@reagents.map(&:to_a)} => #{@amount} #{@product}>"
  end

  def to_reagent(itemtext)
    amount, name = itemtext.split(' ')
    Reagent.new(name: name, amount: amount)
  end

  def to_reagent_list(relist)
    relist.split(', ').map { |x| to_reagent(x) }
  end

  def multiply(x)
    copy = self.dup
    copy.amount = @amount * x
    copy.reagents = @reagents.map do |r|
      rcopy = r.dup
      rcopy.amount = r.amount * x
      rcopy
    end
    copy
  end
end

class Reagent
  attr_accessor :name, :amount

  def initialize(name:, amount:)
    @name = name.upcase.to_sym
    @amount = amount.to_i
  end

  def to_a
    [name, amount]
  end
end

class FuelCalculator
  attr_reader :stack, :fuel, :stockpile, :recipes, :later, :ore
  
  def initialize(fuel:, recipes:)
    @fuel = fuel
    @recipes = recipes
    @ore = 0
    @stack = Hash.new(0)  # things that are required to make :FUEL
    stack[:FUEL] = @fuel
    # need to keep overflow amounts of things along the way. If another
    # rule requires more of that type later, we can check if we have any
    # in the stockpile first before using a rule again and making too much.
    @stockpile = Hash.new(0)
  end
  
  def ore_required
    loop do
      # process one item from the stack
      break if stack.keys.size == 0
      item = pop_from(@stack)
      subtract_extra(item)  # if we have any on the stockpile, use that up first
      if item.amount > 0
        results, extra = apply_rule(item)
        store(results)
        keep_extra(extra)
      end
    end
    @ore
  end

  def inc_fuel!(amount)
    @stack[:FUEL] += amount
    @ore = 0
  end

  private

  def keep_extra(extra)
    @stockpile[extra.name] += extra.amount
  end

  def store(results)
    results.each do |r|
      if r.name == :ORE
        @ore += r.amount
      else
        @stack[r.name] += r.amount
      end
    end
  end

  def apply_rule(item)
    rule = recipes[item.name]
    mult, remain = item.amount.divmod(rule.amount)
    mult += 1 if remain > 0
    # - multiply all the rule.reagents by the multiplier
    newrule = rule.multiply(mult)
    results = newrule.reagents
    extra = newrule.amount - item.amount
    leftover =  Reagent.new(name: item.name, amount: extra)
    return [results, leftover]
  end

  def subtract_extra(reagent)
    extra = stockpile[reagent.name]
    return if extra <= 0
    if extra < reagent.amount
      reagent.amount -= extra
      stockpile[reagent.name] = 0
    else
      # extra >= amount
      diff = extra - reagent.amount
      reagent.amount = 0
      stockpile[reagent.name] = diff
    end
  end

  def pop_from(hash)
    key = hash.keys.first
    result = Reagent.new(name: key, amount: hash[key])
    hash.delete(key)
    result
  end
end


class FuelProducer
  def initialize(recipes:, total_ore:)
    @fuel_count = 1
    @calculator = FuelCalculator.new(fuel: 1, recipes: recipes)
    @opf = @calculator.ore_required
    @total_ore = total_ore - @opf
  end

  def use_next_ore(fuel:)
    inc_fuel!(fuel)
    @calculator.ore_required
  end

  def inc_fuel!(amount)
    @fuel_count += amount
    @calculator.inc_fuel!(amount)
  end

  def use_total_ore!
    # return how much fuel produced
    fuel_amount = 1000
    loop do
      amount = use_next_ore(fuel: fuel_amount)
      @total_ore -= amount
      if @total_ore < amount
        fuel_amount = [fuel_amount / 10, 1].max
      end
      $stderr.puts "remaining ore: #{@total_ore}"
      return @fuel_count if @total_ore == 0
      return @fuel_count - 1 if @total_ore < 0
    end
  end
end

if __FILE__ == $0
  rules = DATA.readlines(chomp: true).map { |ruletext| Rule.new(ruletext) }
  recipes = rules.reduce({}) do |sum, rule|
    sum.merge({ rule.product => rule })
  end
  ore_per_fuel = FuelCalculator.new(fuel: 1, recipes: recipes).ore_required
  puts "part 1: ore = #{ore_per_fuel}"

  # part 2
  # given 1000000000000 :ORE, how much :FUEL can we produce?
  # we know from part one that 443537 :ORE is required for 1 :FUEL.
  # But we also produce a bunch of extra intermediate bits when we produce
  # 1 :FUEL. If we feed in 443537 :ORE several times, how long until we
  # produce 2 :FUEL instead of just 1? It'll mean that every (Y*443537) :ORE,
  # we actually produce (Y+1) :FUEL. Answer will be (1 trillion / (Y*443537)) * (Y+1)
  fuel = 0
  total_ore = 1000000000000
  fp = FuelProducer.new(recipes: recipes, total_ore: total_ore)
  fuel = fp.use_total_ore!
  puts "part 2: with #{total_ore} :ORE we can make #{fuel} :FUEL"
end

__END__
2 LGNW, 1 FKHJ => 3 KCRD
5 FVXTS => 5 VSVK
1 RBTG => 8 FKHJ
2 TLXRM, 1 VWJSD => 8 CDGX
1 MVSL, 2 PZDR, 9 CHJRF => 8 CLMZ
11 BMSFK => 5 JMSWX
10 XRMC => 1 MQLFC
20 ZPWQB, 1 SBJTD, 9 LWZXV => 4 JFZNR
2 FVXTS => 3 FBHT
10 ZPWQB => 8 LGNW
5 WBDGL, 16 KZHQ => 2 FVXTS
124 ORE => 7 BXFVM
5 KCRD => 1 RNVMC
5 CGPZC, 4 WJCT, 1 PQXV => 8 VKQXP
4 KFVH => 4 FGTKD
11 QWQG => 6 LWZXV
9 ZMZPB, 8 KFVH, 5 FNPRJ => 3 VKVP
1 LFQW, 8 PQXV, 2 TLXRM, 1 VKQXP, 1 BMSFK, 1 QKJPV, 3 JZCFD, 8 VWJSD => 6 WXBC
2 SLDWK, 32 JZCFD, 10 RNVMC, 1 FVXTS, 34 LGTX, 1 NTPZK, 1 VKQXP, 1 QTKL => 9 LDZV
31 FBHT => 2 BMSFK
35 KZHQ, 3 ZPWQB => 3 PCNVM
6 DRSG, 1 TDRK, 1 VSVK => 2 VWJSD
3 DGMH => 3 ZPWQB
162 ORE => 9 RBTG
11 LFQW, 1 LPQCK => 8 LGTX
8 MQLFC => 1 SBJTD
1 KGTB => 9 TGNB
1 BXFVM, 1 ZMZPB => 8 FNPRJ
1 PCNVM, 15 ZSZBQ => 4 PQXV
15 XRMC => 9 ZSZBQ
18 VWJSD, 12 CHJRF => 6 KTPH
8 RBTG, 5 ZMZPB => 6 KFVH
6 SLDWK => 1 XVTRS
3 VSVK, 6 BMSFK, 3 NTPZK => 1 JZCFD
3 FVXTS, 2 MTMKN => 5 CHJRF
9 FNPRJ => 2 QWQG
1 FBHT, 1 MVSL, 1 FNPRJ => 1 DRSG
35 LPQCK, 19 LWZXV, 28 LGNW => 5 TLXRM
5 NKMV => 3 QKJPV
3 MGZM, 2 TGNB => 8 PZDR
2 FKHJ => 2 WBDGL
1 NKMV => 1 KGTB
129 ORE => 7 ZMZPB
3 LMNQ, 2 BMSFK, 4 RNVMC, 4 KGTB, 4 DRSG, 2 JFZNR, 7 QTKL => 4 CKQZ
1 MQLFC => 7 MGZM
7 SLDWK, 2 KCRD => 4 WJCT
1 QKJPV => 4 LPQCK
1 JFZNR => 6 TDRK
4 CLMZ, 1 LGTX => 9 PMSZG
6 QWQG => 8 CGPZC
10 QWQG => 6 LMNQ
2 PMSZG, 1 VKVP => 3 QTKL
2 DGMH => 8 KZHQ
14 RBTG => 9 DGMH
62 RNVMC, 4 KTPH, 20 XVTRS, 7 JZCFD, 18 CDGX, 13 WXBC, 14 LDZV, 2 CKQZ, 33 FNPRJ => 1 FUEL
8 KGTB, 1 JMSWX => 7 NTPZK
1 VKVP, 7 DGMH => 7 NKMV
4 LPQCK => 5 MVSL
6 KGTB => 2 LFQW
2 FGTKD => 9 SLDWK
1 WBDGL, 1 ZMZPB, 1 DGMH => 6 XRMC
4 VKVP => 7 MTMKN
