require_relative 'model'
require_relative 'rule'
require_relative 'selector'

                            #block!
class Extractor; is Model(:rule_set!, state: {})
  def feed *nodes
    [*nodes].each do |node|
      (state[Selector[node].to_s] ||= rule_set.call).feed node
    end
  end
end
def Extractor *a,&b; Extractor.new *a,&b end


if __FILE__ == $0
  # load 'test_helper'
  require 'ostruct'; stub =->(a){ OpenStruct.new a }
  require 'testdo'
  test do

  node = stub[text: '123', name: 'div']
  node2 = stub[text: '12', name: 'div']
  Selector[node].to_s === 'div'

  e = Extractor { SimpleRule['text'] }
  e.state === {}

  e.feed node
  e.state['div'].name === ['text']
  e.state['div'].state === ['123']
  
  e.feed node
  e.state['div'].name === ['text']
  e.state['div'].state === ['123']

  e.feed node2
  e.state['div'].name === []
  e.feed node2
  e.state['div'].name === []
  e.feed node
  e.state['div'].name === []
end
end

__END__
class Extractor; is Model(:rules_set, state: nil)

  # attr_reader :state
  # def initialize interest; @interest = interest; @state = {} end
  # def self.[] *a; new *a end
  
  # def feed page
  #   html(page).traverse do |node|
  #     info = NodeInfo[node, interest]
  #     if @state[info.key]
  #       @state[info.key].feed info.value
  #       # @state[info.key] = smart_merge(@state[info.key], info.value)
  #     else
  #       @state[info.key] = 
  #       @state[info.key].feed info.value

  #       # merge! info
  #     end
  #   end
  # end

  # private
  # # attr_reader :interest
  # # def html *a; Nokogiri::HTML *a end    
  # def merge! info
  #   @state.merge! info.hash
  # end
  # def smart_merge scan1, scan2
  #   scan1.keys.each_with_object({}) do |key,result|
  #     result[key] = scan1[key] if scan1[key] == scan2[key]
  #   end
  # end  
end





#   def initialize name, proc, measurement=Record; @name, @proc, @measurement = name, proc, measurement end
#   def self.[] *a; new *a end

#   def scan node
#     measurement.new(self).tap { |x| feed measure node }
#   end
#   def name; @name end
#   def measure node; @proc[node] end
  
#   private
#   attr_reader :measurement
# end




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




# class NodeInfo; is Model(:node, :interest)
#   # def initialize node, interest; @node = node
#   #   @info = {Selector[node].to_s => Scan[node, interest].hash}
#   # end
#   # def self.[] *a; new *a end
#   def info
#     @info ||= {Selector[node].to_s => Scan[node, interest]}
#   end

#   def hash; info end
#   def key; info.keys[0] end
#   def value; info.values[0] end
#   # private
#   # attr_reader :node
# end

__END__
class Scan
  def initialize node, rulers; @node = node
    @scan = [*rulers].map { |x| x.scan(node) } # stages ? ~ values ~ scan
    @scan = @scan.map { |x| x.scan(node) } # stages ? ~ values ~ scan
  end
  def self.[] *a; new *a end

  def to_a; @scan end

  private
  attr_reader :node
end



# class KeyValue
#   def initialize key, value; @key, @value = key, value end
# end


class Record
  attr_reader :state  
  def initialize ruler; @ruler = ruler; @state = nil end

  def feed value, record_set #=:not_needed_on_first_call
    if @state_assigned
      record_set.delete self unless value == state
    else
      self.state = value
      @state_assigned = true
    end
  end

  def name; @ruler.name end
end


class Ruler
  def initialize name, proc, measurement=Record; @name, @proc, @measurement = name, proc, measurement end
  def self.[] *a; new *a end

  def scan node
    measurement.new(self).tap { |x| feed measure node }
  end
  def name; @name end
  def measure node; @proc[node] end
  
  private
  attr_reader :measurement
end

# fabric/constructor methods  # @type?
def MakeRuler given
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
def MakeRulers *given
  [*given].map { |x| MakeRuler x }
end




# class Measurement
#   def initialize given
#     case given
#     when String
#       @name = given
#       @proc = ->(node){ node.instance_eval(given) } 
#     when Hash
#       raise 'o0' if given.keys.count != 1
#       @name = given.keys[0]
#       @proc = given.values[0]
#     when Array
#       raise 'o0' if given.count != 2
#       @name = given[0]
#       @proc = given[1]      
#     else raise :unknown! end
#   end
#   def self.[] *a; new *a end  

#   def name; @name end
#   def scan node; @proc[node] end
#   # def scan node
#   #   proc = @proc
#   #   ->(state){
#   #   }
#   # end
# end



if __FILE__ == $0


  # raise unless %w"to_s text children.count".map { |x| Measurement[x] }.count == 3
  # raise unless %w"to_s text children.count".map { |x| Measurement[x] }.map(&:name) == %w"to_s text children.count"
  # raise unless Measurement['to_s'].scan(123) == '123'

  raise unless Scan[node, Measurement['name']].hash.keys.count == 1
  raise unless Scan[node, [Measurement['name'],Measurement['value']]].hash.keys.count == 2
  raise unless Scan[node, [Measurement['name'],Measurement['value']]].hash.keys == ['name','value']
  raise unless Scan[node, [Measurement['name'],Measurement['value']]].hash.values == ['hey',123]
  





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