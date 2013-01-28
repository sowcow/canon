require_relative 'model'

def Composite *a
  Composite::Compose[*a]
end
alias Compose Composite

# each instance can be a group of instances!
# it does not expose children count, their indexes, etc, so "tell, dont ask"
# components can self-delete, self-replace, or add other ones
module Composite
  class Compose < BasicObject; is Model([:children])
    def initialize *a;super
      children.each { |child| added child }
    end

    def method_missing *a,&b
      children.map { |x|x.send *a,&b }.flatten
    end

    def to_ary; nil end

    def tap &b
      super;self
    end
    def added child
      comp = self; child.instance_eval { @parent = comp }
    end
    def delete who; children.delete who end
    def replace who, what; children[children.index(who)] = what end
    def add to_who,*elements; replace to_who, Compose[to_who,*elements] end
    # def inspect
    #   "#Compose: #{children.map(&:inspect) * ','}"
    # end
  end

  module Node
    def parent; @parent end
    def delete!; @parent.delete self end
    def add! who; parent.add self, who end
    def replace! with_who; parent.replace self, with_who end
  end

  def new *a
    result = Compose[super].tap { |x| x.extend Node }
  end
end

if __FILE__ == $0
require 'testdo'
test do

  class Any; is Model(:number)
    # singleton_class.send :prepend, Composite
    extend Composite    
    
    def add
      add! Any[number + 1]
    end
    def replace
      replace! Any[number + 1]
    end
  end
  X = Composite::Compose


  Any[1].class === [Any]
  Any[1].number === [1]
  X[ Any[1], Any[2] ].number === [1, 2]
  X[ Any[1], X[ Any[2], Any[3] ]].number === [1, 2, 3]

  c = Any[1]
  c.__id__ === c.parent[0].__id__

  c = Any[1]; c.delete!
  c.inspect === []

                        # why not deleteing all tree ? because its .number is array! [1,2,2], etc...
  c = X[ Any[1], Any[2], Any[2] ]; c.tap { |x| x.delete! if x.send(:number) == 2 }
  c.number === [1]

  c = X[ Any[1], Any[2], Any[2] ]; c.tap { |x| x.delete! if x.send(:number) == 1 }
  c.number === [2, 2]

  c = X[Any[1]];
  c.tap { |x| x.add }; c.number === [1, 2]
  c.tap { |x| x.add }; c.number === [1, 2, 2, 3]
  c.tap { |x| x.add }; c.number === [1, 2, 2, 3, 2, 3, 3, 4]
  
  c = X[Any[1]];  
  max = c.number.max; c.tap { |x| x.add if x.send(:number) == max }; c.number === [1,2]
  max = c.number.max; c.tap { |x| x.add if x.send(:number) == max }; c.number === [1,2,3]
  max = c.number.max; c.tap { |x| x.add if x.send(:number) == max }; c.number === [1,2,3,4]
  max = c.number.max; c.tap { |x| x.add if x.send(:number) == max }; c.number === [1,2,3,4,5]

  c = X[Any[1]];
  c.tap { |x| x.replace }; c.number === [2]
  c.tap { |x| x.replace }; c.number === [3]
  c.tap { |x| x.replace }; c.number === [4]
  c.tap { |x| x.replace }; c.number === [5]

  Composite(Any[1],Any[2],Any[3]).number === [1, 2, 3]
  Compose(Any[1],Any[2],Any[3]).number === [1, 2, 3]
end
end

__END__
  # def self.included target
  #   target.instance_eval do
  #     define composite; @composite end
  #     def delete!; composite.delete self end
  #   end
  # end
  # def initialize *children; @children = children; install_attributes end
  # def self.[] *a; new *a end

# class Composite < Array
#   def self.composite_methods
#   end
# end
require 'my-sugar'
require_delegation

class Composite < BasicObject
  def initialize *children; @children = children; install_attributes end
  def self.[] *a; new *a end

  def install_attributes
    comp = self
    children.each do |child|
      child.instance_eval do
        @composite = comp
        def composite; @composite end
        def delete!; composite.delete self end
      end
    end
  end

  delegate *%w[delete push <<], to: :children

  def method_missing *a,&b
    children.map { |x|x.send *a,&b }.flatten
  end
  private; attr_reader :children
end

class My
  def initialize num; @num = num end
  def self.[] *a; new *a end
  def to_s; num.to_s end
  private; attr_reader :num  
  def self.new *a
    Composite[super]
  end

  def to_ary
    [self]
  end
end

if __FILE__ == $0
  trace = TracePoint.new(:call) do |tp|
    p [tp.lineno, tp.defined_class, tp.method_id, tp.event]
  end

  require 'testdo'
  test do
    My[1].to_s == %w[1]
    Composite[My[1],My[2]].to_s == %w[1 2]
    Composite[My[1],Composite[My[2],My[3]]].to_s == %w[1 2 3]

    a = Composite[My[1],Composite[My[1],My[3]]]
    a.delete!
    a.to_s == []

    a = Composite[My[1],Composite[My[1],My[3]]]
    a.tap { |x| x.delete! if x.instance_eval{@num} > 1 }
    a.to_s == %w[1 1]

    my = My[1]
    def my.add_some
      composite << My[2]
    end
    # def my.add_some; composite << My[@num + 1] end

    # trace.enable
    my.add_some
    my.to_s == %w[1 2]
  end
end  