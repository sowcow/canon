require 'nokogiri'


class NodeInfo
  def initialize node, interest; @node = node
    @info = {Selector[node].to_s => Scan[node, interest].hash}
  end
  def self.[] *a; new *a end

  def hash; @info end
  def key; @info.keys[0] end
  def value; @info.values[0] end

  private
  attr_reader :node
end


class Scan
  def initialize node, measurements; @node = node
                                           # same names => loss of values
    @scan = Hash[ *[*measurements].map { |x| [x.name, x.scan(node)] }.flatten(1)]
  end
  def self.[] *a; new *a end

  def hash; @scan end

  private
  attr_reader :node
end


class Selector
  def initialize node; @node = node
    @selector = parents.to_a + [this]
  end
  def self.[] *a; new *a end

  def to_a; @selector end
  def to_s; @selector * ' > ' end

  private
  attr_reader :node
  def parents
    node.respond_to?(:parent) ? Selector[node.parent] : []
  end
  def this
    name = node.name
    id = node[:id] =~ /\d/ ? nil : node[:id]
    klass = node[:class] =~ /\d/ ? nil : node[:class]
    [[node.name, id].compact * '#', klass].compact * '.'
  end
  def inspect; to_s.inspect end
end


class KeyValue
  def initialize key, value; @key, @value = key, value end
end


class Measurement#s
  def initialize given
    case given
    when String
      @name = given
      @proc = ->(node){ node.instance_eval(given) } 
    when Hash
      raise 'o0' if given.keys.count != 1
      @name = given.keys[0]
      @proc = given.values[0]
    when Array
      raise 'o0' if given.count != 2
      @name = given[0]
      @proc = given[1]      
    else raise :unknown! end
  end
  def self.[] *a; new *a end  

  def name; @name end
  def scan node; @proc[node] end
  # def scan node
  #   proc = @proc
  #   ->(state){
  #   }
  # end
end

class Extractor #; is Model(:interest, ) # *init_params, {procs / state}
  attr_reader :state
  def initialize interest; @interest = interest; @state = {} end
  def self.[] *a; new *a end
  
  def feed page
    html(page).traverse do |node|
      info = NodeInfo[node, interest]
      if @state[info.key]
        @state[info.key] = smart_merge(@state[info.key], info.value)
      else
        merge! info
      end
    end
  end

  private
  attr_reader :interest
  def html *a; Nokogiri::HTML *a end    
  def merge! info
    @state.merge! info.hash
  end
  def smart_merge scan1, scan2
    scan1.keys.each_with_object({}) do |key,result|
      result[key] = scan1[key] if scan1[key] == scan2[key]
    end
  end  
end


if __FILE__ == $0
  load 'test_helper'

  # stubs...
  node = stub(name: 'hey', value: 123)
  def node.[] any; nil end
  sub_node = node.clone
  def sub_node.name; 'sub' end
  $node = node; def sub_node.parent; $node end
  interest = [Measurement['name'],Measurement['value']]

  stupid_node1 = node.clone
  def stupid_node1.[] key; {id: 'lol123', :class => 'omg456'}[key] end
  normal_node = node.clone
  def normal_node.[] key; {id: 'id', :class => 'any'}[key] end
  # stubs...

  raise unless %w"to_s text children.count".map { |x| Measurement[x] }.count == 3
  raise unless %w"to_s text children.count".map { |x| Measurement[x] }.map(&:name) == %w"to_s text children.count"
  raise unless Measurement['to_s'].scan(123) == '123'

  raise unless Scan[node, Measurement['name']].hash.keys.count == 1
  raise unless Scan[node, [Measurement['name'],Measurement['value']]].hash.keys.count == 2
  raise unless Scan[node, [Measurement['name'],Measurement['value']]].hash.keys == ['name','value']
  raise unless Scan[node, [Measurement['name'],Measurement['value']]].hash.values == ['hey',123]
  

  raise unless Selector[node].to_s == 'hey'
  raise unless Selector[node].to_a == ['hey']
  raise unless Selector[sub_node].to_a == ['hey','sub']
  raise unless Selector[sub_node].to_s == 'hey > sub'

  raise unless Selector[normal_node].to_s == 'hey#id.any'
  raise unless Selector[stupid_node1].to_s == 'hey'


  raise unless NodeInfo[node, interest].hash == {"hey"=>{"name"=>"hey", "value"=>123}}
  raise unless NodeInfo[node, interest].key == "hey"
  raise unless NodeInfo[node, interest].value == {"name"=>"hey", "value"=>123}

  raise unless Extractor[interest].state == {}

  e = Extractor[Measurement['self[:value]']]
  e.feed '<div value=123>'
  raise unless e.state["document > html > body > div"] == {"self[:value]"=>"123"}
  e.feed '<div value=465>'
  raise unless e.state["document > html > body > div"] == {}
  puts 'OK'
end