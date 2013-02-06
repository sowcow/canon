require_relative 'model'


class Selector; is Model(:node)

  def selector
    @selector ||= parents.to_a + [this]
  end

  def to_a; selector end
  def to_s; selector * ' > ' end

  private
  def parents
    node.respond_to?(:parent) && node.parent ? Selector[node.parent] : []
  end
  def this
    name = node.name
    id = node[:id] =~ /\d/ ? nil : node[:id]
    klass = node[:class] =~ /\d/ ? nil : node[:class]
    [[node.name, id].compact * '#', klass].compact * '.'
  end
  def inspect; to_s.inspect end # private?
end


if __FILE__ == $0
  load 'test_helper'
  # stubs...
  node = stub(name: 'hey', value: 123)
  def node.[] any; nil end
  sub_node = node.clone
  def sub_node.name; 'sub' end
  $node = node; def sub_node.parent; $node end
  # interest = [Measurement['name'],Measurement['value']]

  stupid_node1 = node.clone
  def stupid_node1.[] key; {id: 'lol123', :class => 'omg456'}[key] end
  normal_node = node.clone
  def normal_node.[] key; {id: 'id', :class => 'any'}[key] end
  # stubs...
end  

if __FILE__ == $0  
  raise unless Selector[node].to_s == 'hey'
  raise unless Selector[node].to_a == ['hey']
  raise unless Selector[sub_node].to_a == ['hey','sub']
  raise unless Selector[sub_node].to_s == 'hey > sub'
  raise unless Selector[normal_node].to_s == 'hey#id.any'
  raise unless Selector[stupid_node1].to_s == 'hey'  
end