require 'set'
require 'erb'
#$:.unshift '../lib'


def result template = File.read('output.erb'), data
  ERB.new(template, 0, ?%).result(binding)
end



if __FILE__ == $0
  require 'yaml'
  TEST_DATA = YAML.load <<END
---
document > html:
- text: !ruby/object:Set
    hash:
      '1': true
      '': true
document > html > body:
- children.count: 1
document > html > body > div:
- :attributes:
    class: any
END
  result = result TEST_DATA
  raise unless result =~ /require/
  puts result
  eval result, binding, __FILE__, __LINE__

  raise unless Page::Elements::Element_1.accept?('document > html > body') == true
  raise unless Page::Elements::Element_1.accept?('html - body') == false
  raise unless Page.new.element_classes.include? Page::Elements::Element_1
  raise     if Page.new.element_classes.include? Page::Elements::Base
  raise unless Page.new.element_classes == [Page::Elements::Element_0, Page::Elements::Element_1, Page::Elements::Element_2]
  raise unless Page.new.key(Nokogiri::HTML('<body><div></div></body>').at('body')) == 'document > html > body'
  raise unless Page::Elements::Element_1.accept? Page.new.key(Nokogiri::HTML('<body><div></div></body>').at('body'))
  raise unless Page.new('<body><div></div></body>').elements.map(&:class) == [Page::Elements::Element_2, Page::Elements::Element_1, Page::Elements::Element_0]

  GIVEN = Nokogiri::HTML('<body><div class=any></div></body>')
  WRONG = Nokogiri::HTML('<body><div></div>123<div></div></body>')
  raise unless Page::Elements::Element_1.new(GIVEN.at 'body').valid? == true
  raise unless Page::Elements::Element_1.new(WRONG.at 'body').valid? == false
  raise unless Page::Elements::Element_2.new(GIVEN.at 'div').valid? == true
  raise unless Page::Elements::Element_2.new(WRONG.at 'div').valid? == false
  raise unless Page::Elements::Element_0.new(GIVEN.at 'html').valid? == true
  raise unless Page::Elements::Element_0.new(WRONG.at 'html').valid? == false
  puts 'OK'
end

__END__
#class Page
#  module Elements
#    class Element1 < Base
#      MATCH = /^document > html > body$/
#      
#      def valid?
#        #children.count == 0 &&
#        true
#      end
#    end
#
#    class OtherElement < Base
#      MATCH = /(div|html$)/
#      
#      def valid?
#        #children.count == 0 &&
#        true
#      end
#    end 
#  end
#end
require 'nokogiri'
require_relative 'lib/selector'

module Helpers
  def split html
    [].tap do |nodes|
      Nokogiri::HTML(html).at('html').traverse { |node| nodes << node }
    end
  end
  # def subclasses
  #   ObjectSpace.each_object(Class).select { |klass| klass < self.class }
  # end
  def key node
    Selector[node].to_s
  end
end

class Page
  include Helpers
  attr_reader :elements

  def initialize page_html=nil
    @elements = split(page_html).map { |node| find_element_for node } if page_html
  end
  def valid?
    elements.all? &:valid?
  end

  # private
  def find_element_for node
    found = find_elements(key(node))
    raise "wtf? #{found}" unless found.count == 1
    found = found[0]
    found.new(node)
  end
  def find_elements key
    element_classes.select { |x| x.accept? key }
  end
  def element_classes
    Elements.constants.reject { |x| x == :Base }.map { |x| Elements.const_get(x) }.select { |x| x.is_a? Class }
  end

  module Elements
    
    class Base
      def initialize node; @node = node end
      def self.accept? key
        self::MATCH =~ key ? true: false
      end
    end

    class Element1 < Base
      MATCH = /^document > html > body$/
      
      def valid?
        #children.count == 0 &&
        true
      end
    end

    class OtherElement < Base
      MATCH = /(div|html$)/
      
      def valid?
        #children.count == 0 &&
        true
      end
    end    
  end
end

if __FILE__ == $0
  raise unless Page::Elements::Element1.accept?('document > html > body') == true
  raise unless Page::Elements::Element1.accept?('html - body') == false
  raise unless Page.new.element_classes.include? Page::Elements::Element1
  raise     if Page.new.element_classes.include? Page::Elements::Base
  raise unless Page.new.element_classes == [Page::Elements::Element1, Page::Elements::OtherElement]
  raise unless Page.new.key(Nokogiri::HTML('<body><div></div></body>').at('body')) == 'document > html > body'
  raise unless Page::Elements::Element1.accept? Page.new.key(Nokogiri::HTML('<body><div></div></body>').at('body'))
  raise unless Page.new('<body><div></div></body>').elements.map(&:class) == [Page::Elements::OtherElement, Page::Elements::Element1, Page::Elements::OtherElement]
  # p Page.new('<body><div></div></body>').elements.map(&:class).map(&:name) == [Page::Elements::UnknownElement, Page::Elements::UnknownElement, Page::Elements::UnknownElement]
  # raise unless true
end
