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
# produces it, we can always safely pop it and throw away any excess.
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
    @stack = []
    stack.push(Reagent.new(name: "fuel", amount: @fuel))
    @stockpile = Hash.new(0)
    @later = {}
  end
  
  def ore_required
    loop do
      process_one
      merge_common
      break if stack.size == 0 && later.keys.size == 0
    end
    ore
  end

  def fetch_from_later
    key = later.keys.first
    result = Reagent.new(name: key, amount: later[key])
    later.delete(key)
    result
  end
  
  def process_one
    is_later = false
    if stack.size > 0
      reagent = stack.pop
      $stderr.puts "processing #{reagent.to_a} from stack"
    else
      # get from later pile.
      reagent = fetch_from_later
      $stderr.puts "processing #{reagent.to_a} from later"
      is_later = true
    end
    if reagent.name == :ORE
      @ore += reagent.amount
      $stderr.puts "ore = #{ore}"
      return
    end
    rule = recipes[reagent.name]
    # Before you reduce some reagent to components, you want to make
    # sure that you've done all the other things that can make that reagent.
    # This will help you when the rule says " => 10 Foo" but you have 11 Foo,
    # so you'd normally have to double the rule and increase total requirements.
    # If you'd waited a bit longer, you'd have realized that you have extra
    # Foo coming later for free.
    # On the other hand, it's always safe to do at least one reaction, you
    # just don't want to accidentally multiply when you don't need to.
    #
    # So in our situation here, if reagent.amount is bigger than the amount
    # made by the rule, then we happily reduce once, and then push the
    # remainder back onto the stack because it's still a requirement.
    #
    # On the other side, if the rule says " => 10 Foo" and we've just popped
    # 5 Foo off the stack, then we stash it for later. If we run out of things to
    # reduce on the stack, then we go into the "later" pile and do one of them, which
    # may involve producing extra into the stockpile.

    # add required "later" amount if available
    needed = later[reagent.name]
    if !needed.nil? && needed > 0
      reagent.amount += needed
      later.delete(reagent.name)
    end

    # if a requirement popped off the stack and we have some of that already
    # in the stockpile, then we just subtract the stockpile amount and keep going.
    extra = stockpile[reagent.name]
    if extra > 0
      if extra < reagent.amount
        reagent.amount -= extra
        stockpile[reagent.name] = 0
      else
        # extra >= amount
        diff = extra - reagent.amount
        stockpile[reagent.name] = diff
        return  # work complete
      end
    end

    if reagent.amount >= rule.amount || is_later
      # --> do the rule as many times as we can
      # - find the multiplier
      multiplier = [reagent.amount / rule.amount, 1].max
      # - multiply all the rule.reagents by the multiplier
      #   and push them on the stack.
      newrule = rule.multiply(multiplier)
      results = newrule.reagents
      results.each { |r| stack.push(r) }
      # - subtract the multiplied rule amount from reagent.amount
      if reagent.amount < newrule.amount
        stockpile[reagent.name] += newrule.amount - reagent.amount
      else
        reagent.amount -= newrule.amount
      end
    end
    if reagent.amount > 0
      later[reagent.name] = reagent.amount
    end
  end

  def merge_common
    # if any elements of the stack are the same name, then add them up
    tmp = stack.reduce(Hash.new(0)) do |hash, reagent|
      hash[reagent.name] += reagent.amount
      hash
    end
    stack = tmp.to_a
  end
end

if __FILE__ == $0
  rules = DATA.readlines(chomp: true).map { |ruletext| Rule.new(ruletext) }
  recipes = rules.reduce({}) do |sum, rule|
    sum.merge({ rule.product => rule })
  end
  ore = FuelCalculator.new(fuel: 1, recipes: recipes).ore_required
  puts "part 1: ore = #{ore}"
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
