# 1) validator:
#    - in memory representation?
#    - human readable validation code (kinda rspec)
#    - computer readable result of validation
# 2) extractor itself
#
# fuck memoization and other opt23n for now
# fuck Struct with its to_a
#
# modify selectors if classes ar stupid like a1 a2 a3...?

require 'my-sugar'
require_delegation
require 'nokogiri'
Dir['lib/*.rb'].each { |x| require_relative x }

require 'pp'
require 'pry'
load 'lib/test_helper'



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
    [[node.name, node[:id]].compact * '#', node[:class]].compact * '.'
  end
  def inspect; to_s.inspect end
end


class Measurement
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
    # raise :todo
  end  
end

# attributes.map{|x,y|[x,y.value]}]rescue{}

# measurements = %w"to_s text children.count".map { |x| Measurement[x] }
# measurements = %w"text".map { |x| Measurement[x] }

# page1 = '<html id=wow lang=en><div class=any>any text</html>'
# page2 = '<html id=wow lang=ru><div class=any>other text</html>'

# model = Extractor.new measurements
# model.feed page1
# pp model.state
# p '='*10
# model.feed page2
# pp model.state


if __FILE__ == $0

  # stubs...
  node = stub(name: 'hey', value: 123)
  def node.[] any; nil end
  sub_node = node.clone
  def sub_node.name; 'sub' end
  $node = node; def sub_node.parent; $node end
  interest = [Measurement['name'],Measurement['value']]
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
__END__
interest = %w[to_s text].map { |msg| ->(node){ Hash[msg, node.send(msg)] }} +
           %w[node.children.count].map { |proc| ->(node){ Hash[proc, eval(proc)] }} +
           [->(node){ Hash[node.attributes.map {|x,y|[x,y.value]}] rescue {} }]
__END__


def scan page; page = Nokogiri::HTML page
  nodes = []
  page.traverse do |node|
    nodes << {selector: Selector[node], node: node}
  end
end

measurements = %w[to_s text].map { |msg| ->(node){ Hash[msg, node.send(msg)] }} +
               %w[node.children.count].map { |proc| ->(node){ Hash[proc, eval(proc)] }} +
               [->(node){ Hash[node.attributes.map {|x,y|[x,y.value]}] rescue {} }]


# nodes = scan page1
# puts nodes

def process! nodes, measurements
  nodes.each do |element|; node = element[:node]
    element[:measurements] = measurements.each_with_object({}){ |get,o| o.merge! get[node] }
    # element.delete :node
    element[:node] = nil
  end
  nodes
end; alias process process!

nodes = process(scan(page1), measurements)


class Node
  attr_reader :data
  def initialize node; @node = node
    @data = data_for @node
  end

  private # helpers
  def data_for node
    node
  end
end


class PageModel 
  attr_reader :nodes
  def initialize; @nodes = {} end

  def scan page
    HTML(page).traverse do |node|
      scanned = Scan.new node
      if @nodes[scanned.selector]
        
      else
        @nodes[scanned.selector] = scanned
      end
    end
  end

  delegate :HTML, to: Nokogiri
end




require 'yaml'
puts YAML.dump nodes


__END__
# remove scripts?
def process node
  stuff = %w[name text to_s]

  attributes = Hash[node.attributes.map {|x,y|[x,y.value]}] rescue {}
  element = Hash[stuff.map { |x| [x, node.send(x)] rescue nil }.compact].
              merge(attributes)
                                                                          
  children = node.children.map { |x| process x }

  {element: element, children: children}
end

page1 = process page1
page2 = process page2

puts page1, page2

def decrease node1, node2
  element = node1[:element].keys.
              select { |key| node1[:element][key] == node2[:element][key] }.
              each_with_object({}){|key,result| result[key] = node1[:element][key]}
  children = []              
  {element: element, children: children}
end

puts decrease(page1, page2)

def structure *pages

end