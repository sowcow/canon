require_relative 'model'


class Rule; is Model(:name, :getter, state: nil, state_assigned: false)
  def feed node, rule_set
    value = getter[node]
    if state_assigned
      state == value ? :OK : delete_from(rule_set)
    else
      assign_state value
    end
  end

  private
  def delete_from rule_set
    @state = nil
    rule_set.delete(self)
  end
  def assign_state value
    @state = value
    @state_assigned = true
  end
end
class SimpleRule
  def self.new command
    Rule.new command, ->(node){ node.instance_eval command }
  end
  def self.[] *a; new *a end
end

if __FILE__ == $0
  raise unless SimpleRule.new('to_s').tap{|x|x.feed(123,[])}.state == '123'
  raise unless SimpleRule.new('to_s').tap{|x|x.feed(123,[])}.tap{|x|x.feed('123',[])}.state == '123'

  rules = [SimpleRule.new('to_s')]
  rules[0].feed 123, rules
  raise unless rules[0].state == '123'
  rules[0].feed '123', rules
  raise unless rules[0].state == '123'
  (r = rules[0]).feed 100, rules
  raise unless r.state == nil
  raise unless rules.count == 0
  puts 'OK'  
end


class RuleSet; is Model(:pairs)
  def instantiate
    pairs.each_slice(2).map { |klass,params| klass.new *params }
  end
end
def Rules *pairs; RuleSet[pairs] end

if __FILE__ == $0
  raise unless Rules(String, '2', String, '10').instantiate == ['2','10']
  raise if (r = Rules(String, '2')).instantiate[0].equal? r.instantiate[0]

  puts 'OK'
end