module Helpers
  def split html
    [].tap do |nodes|
      Nokogiri::HTML(html).at('html').traverse { |node| nodes << node }
    end
  end
end

class Page
  include Helpers
  attr_reader :elements

  def initialize page_html
    @elements = split(page_html).map { |node| find_element_for node }
  end

  private
  def find_element_for node
    found = find_elements(key(node))
    raise "wtf? #{found}" unless found.count == 1
    found = found[0]
    found.new(node)
  end
  def find_elements key
    subclasses(self.class).select { |x| x.accept? key }
  end

  module Elements
    
    module Base
      def accept? key
        self.class::MATCH =~ key
      end
    end

    class Element1; extend Base
      MATCH = /^html > body$/
      
      ### nice to have ###
      #def valid?
      #  children.count == 0 &&
      #end
    end
  end
end

if __FILE__ == $0
  raise unless true
end
