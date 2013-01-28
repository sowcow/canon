require_relative 'model'
require_relative 'composite'
require 'my-sugar'
# require_delegation


module ValidateState
  private
  def state= value
    super
  end
end


class Rule; is Model(:name, :getter, state: nil, state_assigned: false)
  # singleton_class.send :prepend, Composite
  extend Composite

  def feed node
    feed_value getter[node]
  end
  
  def feed_value value
    if state_assigned
      act value
    else assign_state(value);
      act value
    end    
  end

  def act value
    raise 'abstract method'
  end

  def to_hash
    Hash[*pair] #{name => state} #Hash[*pair] #{name => state}
  end
  def pair
    [name, state]
  end  

  private
  def assign_state value
    self.state = value
    @state_assigned = true
  end
end

class CommandRule < Rule # prepended superclass!
  def initialize command, lambda=nil
    super command, lambda || ->(node){ node.instance_eval command }
  end
end

class SimpleRule < CommandRule
  def act value
    state == value ? :OK : delete!
  end
end

require 'set'
class SetRule < CommandRule
  def act value
    state.include?(value) ? :OK : self.state = self.state << value # trigger setter
  end
  def assign_state value
    super; self.state = Set[value]
  end  
end

class RangeRule < CommandRule
  def act value
    unless state.include? value # untested line :]
      self.state = Range.new [state.min,convert(value)].min, [state.max,convert(value)].max
    end
  # rescue
  #   delete! # bad values for range?
  end
  def assign_state value
    super; self.state = Range.new convert(value), convert(value)
  end

  private
  def convert value; value.to_i end
end

class FloatRangeRule < RangeRule
  def convert value; value.to_f end  
  # prepend ValidateState
end

class DifferenceRule < CommandRule
  def act value
    unless (diff = value - state).empty?
      self.state = state + diff
    end
  end
  def assign_state value
    super; self.state = value.uniq
  end  
end

class RegexpRule < CommandRule
  def act value
    unless value =~ to_re
      update_state value
    end
  end
  def to_re
    head, tail, full = state[:head], state[:tail], state[:full]
    full ? /^#{Regexp.escape head}.*$/m : /^#{Regexp.escape head}.*#{Regexp.escape tail}$/m
  end
  def assign_state value
    super
    self.state = {}
    self.state[:head] = value
    self.state[:tail] = value
    state[:full] = true
  end

  def update_state value
    state[:head] = head(state[:head], value)
    state[:tail] = tail(state[:tail], value)
    state[:full] = value.size == state[:head].size
    raise "wtf with regexp: #{to_re} !~ #{value}" unless to_re =~ value
  end

  # def to_hash
  #   {name => to_re}
  # end
  def pair; [name, to_re] end

  private
  def head str1, str2
    str2 = str2.chars
    str1.chars.take_while { |c| c == str2.shift }.join
  end
  def tail str1, str2
    head(str1.reverse, str2.reverse).reverse
  end
  # tests in regexp_for
end



module Chained
  def replace_with! klass, values = [*state]
    new = klass.new name, getter
    new.extend Chained
    values.each { |value| new.feed_value value }
    replace! new  
  end

  def act value
    case
    when self.class == SimpleRule && state != value
      replace_with! SetRule, [state,value]

    when self.class == SetRule && state.size == 10 && ! state.include?(value)
      case value
      when Numeric then replace_with! RangeRule, [*state,value]
      when Array #&& [*state].all?&x{ is_a? Array }
        replace_with! DifferenceRule, [[*state].flatten,value]
      when String #&& [*state].all?&x{ is_a? Array }
        replace_with! RegexpRule, [*state, value]#, #[[*state],value]
      else
        raise 'wtf!'
      end
    else super end
  end
end
# refactoring fixed behavior...

class FlexibleRule < SimpleRule
  def self.new *a
    SimpleRule.new(*a).tap &x{ extend Chained }
  end
end



class AttributesRule; is Model(state: {}, )
  extend Composite
  def feed node
    return unless node.respond_to? :attributes
    feed_value Hash[node.attributes.map{|k,v|[k, typecasted(v.value) ]}] 
  end
  def feed_value hash
    hash.each do |key,value|
      (state[key] ||= FlexibleRule[key]).feed_value value # typecasted...
    end
  end

  def to_hash
  #   # {}
    # require 'pry'
    # binding.pry
    all = state.merge(state){|k,v| v.pair[1] } #(&:to_hash) #.map(&:pair)
    # p all
    # hash = all.each_with_object({}){|x,o| o[x[0]] = x[1] }
    {attributes: all}
  #   raise 'lost values?' unless all.size == hash.size
  #   {attributes: hash}
  end
  #   all = state.map(&:to_hash)
  #   hash = all.each_with_object({}){|k,v| }
  #   {attributes:  }
  #   # {:attributes => state.merge(state){|k,v| raise unless v.state.size == 1; v.to_hash[0] } }
  # end

  private
  def typecasted(str) # to test
    [str.to_i, str.to_f, str].find { |cast| cast.to_s.sub(?,,?.) == str.sub(?,,?.) }
  end
  # def act value
  #   unless (diff = value - state).empty?
  #     self.state = state + diff
  #   end
  # end
  # def assign_state value
  #   super; self.state = value.uniq
  # end  
end



if __FILE__ == $0
require 'testdo'
test do
  SimpleRule['to_s'].tap{|x|x.feed(123)}.state === ['123']
  SimpleRule['to_s'].tap{|x|x.feed(123)}. tap{|x|x.feed('123')}.state === ['123']
  SimpleRule['to_s'].tap{|x|x.feed(123)}. tap{|x|x.feed('1234')}.state === []

  rule = SimpleRule.new('to_s')
  rule.feed 123
  rule.state === ['123']
  rule.feed 123
  rule.state === ['123']
  rule.feed 1234
  rule.state === []

  rule = Compose(SimpleRule['to_s'],SimpleRule['to_i'],SimpleRule['to_f'],SimpleRule['to_r'])
  rule.feed 7.5
  rule.state === ["7.5", 7, 7.5, 15/2.to_r]

  rule = SetRule['to_s']
  rule.feed 123
  rule.state.map(&:to_a) === [['123']]
  rule.feed 123
  rule.state.map(&:to_a) === [['123']]
  rule.feed 1234
  rule.state.map(&:to_a) === [['123', '1234']]

  rule = SetRule['to_a']
  rule.feed [1,2]
  rule.state.map(&:to_a) === [[[1,2]]]


  rule = RangeRule['to_s']
  rule.feed 1
  rule.state === [(1..1)]
  rule.feed 2
  rule.state === [(1..2)]
  rule.feed -2
  rule.state === [(-2..2)]
  rule.feed 0
  rule.state === [(-2..2)]
  rule.feed 10.5
  rule.state === [(-2..10)]

  rule = FloatRangeRule['to_s']
  rule.feed 1.2
  rule.state === [(1.2..1.2)]
  rule.feed 2.1
  rule.state === [(1.2..2.1)]
  rule.feed -2
  rule.state === [(-2..2.1)]
  rule.feed 0
  rule.state === [(-2..2.1)]
  rule.feed 10.5
  rule.state === [(-2..10.5)]  
  rule.name === ['to_s'] 

  rule = SimpleRule['to_i'].tap &x{ extend Chained }
  rule.feed '1'
  rule.state === [1]
  rule.feed '1'
  rule.state === [1]
  rule.feed '2'
  rule.state === [Set[1, 2]]
  rule.feed '2'
  rule.state === [Set[1, 2]]
  rule.feed '3'
  rule.state === [Set[1, 2, 3]]  
  %w[4 5 6 7 8 9 10].each { |x| rule.feed x }
  rule.state === [Set[*1..10]]   
  rule.feed '11'
  rule.state === [1..11]   
  rule.feed '-11'
  rule.state === [-11..11]   

  rule = DifferenceRule['tap{}'] #.tap &x{ extend Chained }
  rule.feed [1,1,1,1]
  rule.state === [1]
  rule.feed [1]
  rule.state === [1]
  rule.feed [1,2]
  rule.state === [1,2]
  rule.feed [1,2,3]
  rule.state === [1,2,3]
  rule.feed [1,2,1,2,3,1,2,3]
  rule.state === [1,2,3]

  rule = SetRule['tap{}'].tap &x{ extend Chained }
  rule.feed [1,2]
  rule.state === [Set[[1,2]]]
  rule.feed [2,1]
  rule.state === [Set[[1,2],[2,1]]]
  8.times.map { |i| [rand(1..2)] * i }.each { |x| rule.feed [x] }
  rule.state.map(&:class) === [Set]
  rule.state.map(&:size) === [10]
  rule.feed [1,2,3]
  rule.state === [*1..3] # DifferenceRule now

  rule = RegexpRule['tap{}']
  rule.feed 'abcde'
  rule.to_re === [/^abcde.*$/m]
  rule.feed 'abcd'
  rule.to_re === [/^abcd.*$/m]
  rule.feed 'abacd'
  rule.to_re === [/^ab.*$/m]

  rule = RegexpRule['tap{}']
  rule.feed 'abcde'
  rule.to_re === [/^abcde.*$/m] # abcde is better
  rule.feed 'abde'
  rule.to_re === [/^ab.*de$/m]
  rule.feed 'acde'
  rule.to_re === [/^a.*de$/m]
  rule.feed 'acce'
  rule.to_re === [/^a.*e$/m]
  rule.feed 'cc'
  rule.to_re === [/^.*$/m]

  rule = RegexpRule['tap{}']
  rule.feed 'aaaaa'  
  rule.to_re === [/^aaaaa.*$/m]
  rule.feed 'aaa'  
  rule.to_re === [/^aaa.*$/m] # aa.*a is better
  rule.feed 'aba'  
  rule.to_re === [/^a.*a$/m] # magic
  rule.feed 'aa'  
  rule.to_re === [/^a.*a$/m]
  rule.feed 'a'  
  rule.to_re === [/^a.*$/m]
  rule.feed ''  
  rule.to_re === [/^.*$/m]


  rule = SetRule['tap{}'].tap &x{ extend Chained }
  # (-10..-1).map { |x| x=(-x*2)+2; 'a'*x + 'b'*x }.each do |food|
  20.downto(11).map { |x| 'a'*x + 'b'*x }.each do |food|
    rule.feed food
    rule.state.map(&:class) === [Set]
  end
  rule.state.map(&:size) === [10]  

  rule.feed 'aabb'
  rule.to_re === [/^aa.*bb$/m]
  rule.feed 'aa'
  rule.to_re === [/^aa.*$/m]


  rule = SimpleRule['tap{}'].tap &x{ extend Chained }
  rule.feed 'a'*21 + 'b'*21
  rule.state.map(&:class) === [String]

  20.downto(12).map { |x| 'a'*x + 'b'*x }.each do |food|
    rule.feed food
    rule.state.map(&:class) === [Set]
  end
  rule.state.map(&:size) === [10]  

  rule.feed 'aabb'
  rule.to_re === [/^aa.*bb$/m]
  rule.feed 'aa'
  rule.to_re === [/^aa.*$/m]


  rule = FlexibleRule['tap{}'] #.tap &x{ extend Chained }
  rule.feed 'a'*21 + 'b'*21
  rule.state.map(&:class) === [String]

  20.downto(12).map { |x| 'a'*x + 'b'*x }.each do |food|
    rule.feed food
    rule.state.map(&:class) === [Set]
  end
  rule.state.map(&:size) === [10]  

  rule.feed 'aabb'
  rule.to_re === [/^aa.*bb$/m]
  rule.feed 'aa'
  rule.to_re === [/^aa.*$/m]  



  require 'nokogiri'
  rule = AttributesRule.new
  rule.feed Nokogiri::HTML('<span att=123></span>').at('span')
  rule.to_hash === [{:attributes=>{"att"=>123}}]
  rule.feed Nokogiri::HTML('<span att=100></span>').at('span')
  rule.to_hash === [{:attributes=>{"att"=>Set[123,100]}}]
  8.times do |i| rule.feed Nokogiri::HTML("<span att=#{i}></span>").at('span') end

  # p rule.to_hash
  # exit

  rule.to_hash[0][:attributes]['att'].size === 10
  rule.feed Nokogiri::HTML('<span att=11></span>').at('span')
  rule.to_hash === [{:attributes=>{"att"=>0..123}}]

  rule = AttributesRule.new
  rule.feed Nokogiri::HTML('<span att=123></span>') # should not raise: undefined method `attributes'








  # rule.state === [Set[[1,2]]]
  # rule.feed [2,1]
  # rule.state === [Set[[1,2],[2,1]]]
  # 8.times.map { |i| [rand(1..2)] * i }.each { |x| rule.feed [x] }
  # rule.state.map(&:class) === [Set]
  # rule.state.map(&:size) === [10]
  # rule.feed [1,2,3]
  # rule.state === [*1..3] # DifferenceRule now  
end
end


__END__
# module Rules
#   module_function
#   EVAL = ->(node){ node.instance_eval command }
#   def self.simple command
#     Rule.new Cores::ExactValueOrNothing[command, EVAL]
#   end  
# end

# class Rule; is Model(:name, :getter, state: nil, state_assigned: false)
#   def feed node, rule_set
#     value = getter[node]
#     if state_assigned
#       state == value ? :OK : delete_from(rule_set)
#     else
#       assign_state value
#     end    
#   end

#   private
#   def delete_from rule_set
#     @state = nil
#     rule_set.delete(self)
#   end
#   def assign_state value
#     @state = value
#     @state_assigned = true
#   end
# end

module Rules
  class Rule < Array; is Model(:core) # state
    # def replace new_core; @core = new_core end
    delegate *%w[name feed nil?], to: :core
  end

  module Cores
    class ExactValueOrNothing; is Model(:name, :getter, :container, state: nil, state_assigned: false)
      
      def feed; value = getter[node]
        if state_assigned
          state == value ? :OK : remove(self)
        else
          assign_state value
        end            
      end

      delegate :delete, to: :container
    end
  end

  EVAL = ->(node){ node.instance_eval command }

  def self.simple command
    Rule.new Cores::ExactValueOrNothing[command, EVAL]
  end
end


# class SimpleRule
#   def self.new command
#     Rule.new ExactValueOrNothing[command, ->(node){ node.instance_eval command }]
#   end
#   def self.[] *a; new *a end
# end


if __FILE__ == $0
  # include Rules
  require 'testdo'
  test do
    Rules.simple('to_s').tap{|x|x.feed(123,[])}.state == '123'
    SimpleRule.new('to_s').tap{|x|x.feed(123,[])}.tap{|x|x.feed('123',[])}.state == '123'

    rules = [SimpleRule.new('to_s')]
    rules[0].feed 123, rules
    rules[0].state == '123'

    rules[0].feed '123', rules
    rules[0].state == '123'

    (r = rules[0]).feed 100, rules
    r.state == nil
    rules.count == 0
  end
end

class RuleArray < Array
  def compact!
    self.reject! &:nil?
  end
end

class RuleSet; is Model(:pairs)
  def instantiate
    RuleArray[ pairs.each_slice(2).map { |klass,params| klass.new *params }
                    ]
  end
end
def Rules *pairs; RuleSet[pairs] end

if __FILE__ == $0
  require 'testdo'
  test do
    Rules(String, '2', String, '10').instantiate == ['2','10']
    (r = Rules(String, '2')).instantiate[0].equal?(r.instantiate[0]) == false
  end
end