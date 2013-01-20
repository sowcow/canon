# 1) validator:
#    - in memory representation?
#    - human readable validation code (kinda rspec)
#    - computer readable result of validation
# 2) extractor itself
require 'nokogiri'
Dir['lib/*.rb'].each { |x| require_relative x }

page1 = Nokogiri::HTML '<html id=wow lang=en><div class=any>any text</html>'
page2 = Nokogiri::HTML '<html id=wow lang=ru><div class=any>other text</html>'

class Selector
  attr_reader :node # for local usage
  def initialize node; @node = node
    @selector = parents.to_a + [this]
  end
  def self.[] *a; new *a end

  def to_a; @selector end
  def to_s; @selector * ' > ' end

  private
  def parents
    node.respond_to?(:parent) ? Selector[node.parent] : []
  end
  def this
    [[node.name, node[:id]].compact * '#', node[:class]].compact * '.'
  end
  def inspect; to_s.inspect end
end

def selector node
  path = (selector(node.parent) rescue []).flatten
  this = [[node.name, node[:id]].compact * '#', node[:class]].compact * '.'
    # ||node[:class]].compact * '-'
  path + [this]
end

nodes = []
page1.traverse do |node|
  nodes << {selector: Selector[node], node: node}
end
# puts nodes




measurements = %w[to_s text].map { |msg| ->(node){ Hash[msg, node.send(msg)] }} +
               %w[node.children.count].map { |proc| ->(node){ Hash[proc, eval(proc)] }} +
               [->(node){ Hash[node.attributes.map {|x,y|[x,y.value]}] rescue {} }]

nodes.each do |element|; node = element[:node]
  element[:measurements] = measurements.each_with_object({}){ |get,o| o.merge! get[node] }
end

# puts
puts nodes


exit 0



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