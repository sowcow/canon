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
  singleton_class.send :prepend, Composite

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
    {name => state}
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
    self.state = Range.new [state.min,convert(value)].min, [state.max,convert(value)].max
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
      replace_with! RangeRule, [*state,value]
    else super end
  end
end
# refactoring fixed behavior...


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

  rule = DifferenceRule['tap{}'].tap &x{ extend Chained }
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