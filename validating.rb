#encoding: utf-8
require 'pp'
require 'my-sugar'
require 'nokogiri'
require_delegation
require_relative 'canon'

module Rules
  def should_equal one, two
    [->(element){ one.call(element) == two.call(element) },
     ->(element){ puts "failed: #{ one.call(element).inspect } == #{ two.call(element).inspect }" }]
  end

  def replies message, result
    should_equal ->(e){ e.send(message) }, ->(e){ result }
  end
  def has_attribute name, value
    should_equal ->(e){ e[name] }, ->(e){ value }
  end
  def returns result, &block
    should_equal block, ->(e){ result }
  end  

  def has_children *given
    replies :children, [*given]
  end
  def class_is given
    has_attribute :class, given
  end
  def has_children_names *given
    returns([given].flatten){ |e| e.children.map_{ name } }
  end
  def has_children_classes *given
    returns([given].flatten){ |e| e.children.map { |x| x[:class] } }
  end  

  def inspect!
    [->(e){ puts '>>'; puts e.children.map(&:name); puts e.attributes if e.respond_to? :attributes; false }, ->(e){}]
  end    
end


module CanonStuff
  def wrap element
    klass_name = (element[:class] || element.name).capitalize
    const_get(klass_name).new element
  end
  def valid? html
    wrap(Nokogiri::HTML(html)).valid?
  end
end


module Canon; extend CanonStuff

  class Validator < Struct.new :element; extend Rules

    def valid?; e = element; rules.all? { |x| x[0].call(e).tap { |f| x[1].call(e) unless f } }
    end
    def rules; self.class.instance_variable_get :@rules
    end
    def self.rules *a; (@rules ||= []).push *a
    end
  end

  class Document < Validator
    rules has_children_names(%w[html html]), has_children_classes(nil,nil)
  end
end


p Canon.valid? random_page[:html]
exit

if __FILE__ == $0

  #########################################

  validator = class TestValidator < Canon::Validator
    rules has_children('head','body')
    self
  end
  mock = 'mock'
  def mock.children; ['head','body'] end
  raise unless validator.new(mock).valid? == true
  def mock.children; 123 end
  raise unless validator.new(mock).valid? == false

  #########################################

  validator = class TestValidator2 < Canon::Validator
    rules class_is('given')
    self
  end
  mock = 'mock'
  def mock.[] x; 'given' end
  raise unless validator.new(mock).valid? == true
  def mock.[] x; 456 end
  raise unless validator.new(mock).valid? == false
  
  #########################################

end


BEGIN{
  def all_pages filter=ALL
    pages = WTP.get.only!(filter).parts.map { |part| part.pages.map { |p| {part: part, html: p.html} } }.flatten(1)
  end  
  def random_page; all_pages.sample end
}


__END__
  # module VinayaAndFourNikayas
  #   FILTER = VINAYA + FOUR_NIKAYAS
  #   class Document < Validator
  #     rules has_children('head','body'), class_is(nil)
  #   end
  #   module_function
  #   def wrap element
  #     klass_name = (element[:class] || element.name).capitalize
  #     const_get(klass_name).new element
  #   end
  # end
module LogFalseAssertations
  [Array, String].each do |klass|
  refine klass do
    def == other
      # caller_info = $oh #caller[3] #[/`.*'/][1..-2]
      super.tap { |x| unless x
        # puts "#{caller_info}:"
        puts "#{self.inspect} <> #{other.inspect}"
      end }
    end
  end
  end
end
using LogFalseAssertations
__END__
# using LogFalseAssertations
# '' == '123'
# __END__

module RuleDSL

  def rule name, &check_rule
    define_method name do |*a|
      Module.new do
        define_method :valid? do
          $oh = self.class
          super() && check_rule.call(element,*a)
        end
      end
    end
  end
end


module Rules; extend RuleDSL

  using LogFalseAssertations

  rule :name_is do |element,given|
    element.name == given
  end
  rule :attribute_is do |element,attribute,given|
    element[attribute] == given
  end  
  rule :has_children do |element,*given|
    element.children.map(&:name) == given
  end


  def class_is given
    attribute_is :class, given
  end


  def rules *a; prepend *a end
end



module Canon
  class Validator < Struct.new :element; extend Rules
    def valid?; true end
  end

  module VinayaAndFourNikayas
    FILTER = VINAYA + FOUR_NIKAYAS
    
    class Document < Validator
      rules has_children('head','body'), class_is(nil)
    end

    module_function
    def wrap element
      klass_name = (element[:class] || element.name).capitalize
      const_get(klass_name).new element
    end
  end
end


def valid? html, validator = Canon::VinayaAndFourNikayas
  validator.wrap(Nokogiri::HTML(html)).valid?
end

p valid? random_page[:html]



puts 'OK'



BEGIN{
  def all_pages filter=ALL
    pages = WTP.get.only!(filter).parts.map { |part| part.pages.map { |p| {part: part, html: p.html} } }.flatten(1)
  end  
  def random_page; all_pages.sample end
}

__END__
# BEGIN{ # all_pages method

#   module IncludeAll
#     def self.include? any; true end
#   end  

#   def all_pages filter=IncludeAll
#     pages = WTP.get.only!(filter).parts.map { |part| part.pages.map { |p| {part: part, html: p.html} } }.flatten(1)
#     # pages.map { |x| FlatPage.new x }
#   end
# }
#############################################################
__END__
#############################################################
#                                                           #
#   CAUTION: reading this file can be big a waste of time   #
#                                                           #
#############################################################

# THIS WAY FOR NOW: extracting invariants like: the pages has only one header
# alternative: (all nodes ~> those who unchanged? ~> those who are stupid/unused info ~> result!!!)

########################
# all -> db , element.attr -> json field for each table?
########################


# i should never use standart #children method (in first half of this file), it sucks
# i should never use standart #children method, it sucks
# i should never use standart #children method, it sucks
# i should never use standart #children method, it sucks
# i should never use standart #children method, it sucks
# i should never use standart #children method, it sucks
# i should never use standart #children method, it sucks
# i should never use standart #children method, it sucks
# i should never use standart #children method, it sucks
# i should never use standart #children method, it sucks
# i should never use standart #children method, it sucks
class Nokogiri::XML::Element
  def children!
    children.reject &BLANK
  end
  BLANK = ->(node){ node.to_html.strip == '' }
end

class FlatPage; is Model
  attribute :part
  attribute :html

  def title
    head_tag.at('title').content
  end
  def title2
    h1_title.text # raise :implement_using_title
  end   

  ######################
  ##  TODO: use .nav  ##
  ######################
  def navigation
    head_tag.css('link').map do |link|
      [link[:rel], link[:href]]
    end.flatten.tap { |x| return Hash[*x].tap &x{ delete 'shortcut icon' } }
  end
  def menu
    raise :implement_using_block_0
  end
  def breadcrumbs
    raise :implement_using_breadcrumb
  end  
  def last_edited_by
    user = main_node.children![4]
    date = main_node.children![5].text.strip
    {name: user.text, href: user[:href], date: date}
  end
  ######################
  ## TODO: TODO, TODO ##
  ######################

  # def reload!; @doc = nil end
  # def doc; @doc ||= HTML html end
  def doc; @doc ||= HTML html end
  def html_tag; at doc, 'html' end
  def head_tag; at doc, 'head' end
  def body_tag; at doc, 'body' end
  def header; at body_tag, '#header' end
  def footer; at body_tag, '#footer' end
  def content; at body_tag, '#content' end
  def content_; content.children![0] end

  def left_sidebar; at content_, '#sidebar-left' end
  def sidebar; at left_sidebar, '#sidebar-left-div' end
  def block_0; at sidebar, '#block-tipitaka-0' end

  def table_main;  at content_, '#table-main' end
  def main; table_main.children![1] end

  def breadcrumb; at main, '.breadcrumb' end
  def tabs; at main, '.tabs' end
  def h1_title; at main, 'h1.title' end
  def main_node; at main, '.node' end
  def content_node; main_node.children![2] end
  def nav; content_node.children![3] end
  def body_wrapper; content_node.children![2] end
  def tipitaka_node; body_wrapper.children![0] end

  # move trash[nodes] out of methods?

  def at node, selector
    found = node.css(selector)
    found.count == 1 ? found.first : raise("found #{found.count} nodes using #{selector.inspect}")
    # node.css(selector).tap {|x| raise "found #{x.count} nodes" unless x.count == 1 }.first
  end
  # def content; doc.at 'div.content' end
  def is_trash name; data = yield
    $trash ||= {}
    $trash[name] ||= data
    data == $trash[name]
  end

  # TOC = ->(x){x.text == "On Display : Table of Contents"}

  def valid?
    # require'pry';binding.pry
    return false unless children(html_tag) == %w[head body]
    return false unless children(head_tag) - %w[script style link meta] == %w[title]
    return false unless (1..3) === navigation.keys.count
    
    return false unless children_id(body_tag) == %w[header content footer]

    footer.xpath("//script").remove
    return false unless footer.text.strip == 'Copyright © 2005 - 2012 Dhamma Society - dhammasociety.org. email : worldtipitaka@dhammasociety.org'
    return false unless header.text.strip == ''
    return false unless content.children.count == 1

    return false unless children_id(content.children[0]) == %w[sidebar-left table-main]
    
    return false unless children_id(left_sidebar) == %w[sidebar-left-div]

    return false unless children_id(sidebar) == ["block-tipitaka-0", "block-block-7", "block-block-13", "block-block-6", "block-block-4", "block-tipitaka-2", "block-user-1", "block-user-0"]
    
    sidebar.css('#block-tipitaka-0').remove
    # $trash[:sidebar] ||= sidebar.text # text < to_s # to_s ~ return false
    # return false unless sidebar.text == $trash[:sidebar]
    return false unless is_trash :sidebar do sidebar.text end


    return false unless children_id(table_main) == ["statement", "main"]

    return false unless table_main.children![0].text.strip == 'Tipiṭaka Studies in Theravāda Buddhasāsana'
    
    return false unless children_class(main) == ["breadcrumb", "title", "tabs", "node"]
    
    # $trash[:tabs] ||= tabs.to_s # text < to_s # to_s ~ return false
    # return false unless tabs.to_s == $trash[:tabs]
    return false unless is_trash :tabs do tabs.to_s end

    return false unless title[title2]
    # once { p children_class(main_node) }
    # require'pry';binding.pry

    return false unless children(main_node) == ["span", "span", "div", "text", "a", "text"]
    return false unless children_class(main_node) == ["submitted", "taxonomy", "content", nil, nil, nil]

    return false unless is_trash :span0 do main_node.children![0].to_s end
    return false unless is_trash :span1 do main_node.children![1].to_s end
    return false unless is_trash :span3 do main_node.children![3].to_s end # "Last edited by:"

    return false unless last_edited_by[:href] =~ /^user\//
    return false if last_edited_by[:date].empty? || last_edited_by[:name].empty?

    return false unless children_class(content_node) == [nil, nil, nil, "tipitaka-navigation"]
    return false unless children_id(content_node) ==  [nil, "ajax_loader", "tipitakaBodyWrapper", nil]
    return false unless children(content_node) ==  ["div", "div", "div", "div"]

    return false unless is_trash :auth do content_node.children![0].to_s end
    return false unless is_trash :ajax_loader do content_node.children![1].to_s end
    # return false unless is_trash :ajust_height do content_node.children![...].to_s end # script tags already removed?...

    return false unless children_class(nav) == ["menu", "page-links clear-block"] ||
                        children_class(nav) == ["page-links clear-block"]

    return false unless children(body_wrapper) == ["div"]
    return false unless children_class(body_wrapper) == ["tipitakaNode"]

    known = %w[hidden quotation CENTER ENDH3 SUMMARY ENDBOOK]
    got = children_class(tipitaka_node)
    # puts (got - known) if (got - known).any?
    # some_times { p (got - known) }
    return false if (got - known).any?


    they = tipitaka_node.children!
    return false unless they.map {|x| wrap(x).extend(Logger) }.all? { |x|x.valid? }


    # empty_ones = %w[hidden CENTER ENDH3 SUMMARY ENDBOOK]
    # empty_ones.each do |that_class|
    #   return false unless they.select {|x|x[:class] == that_class}.all_{children.none?}
    # end
    # (known - empty_ones).each do |that_class|
    #   return false if they.select {|x|x[:class] == that_class}.any_{children.none?}
    # end
    # empty_elements = tipitaka_node.children!.reject {|x|x[:class] == 'quotation'} #.reject &TOC
    # return false
    # unless empty_elements.empty?
    #   p empty_elements
    #   return false
    # end

    # "On Display : Table of Contents"

    # return false unless tipitaka_node
    # some_times { p children_class(tipitaka_node) }

    # return false unless children_class(body_wrapper) == ["tipitakaNode"]
    # p children_class(nav)    
    # once { p children_class(body_wrapper) }

    # once { p last_edited_by[:href] }
    # return false unless main_node.children![0].text ==) == ["span", "span", "div", "text", "a", "text"]
    # once { p title[title2] }
    # p children_id(sidebar) if rand(0..10) == 0
    # once { p children_id(sidebar) }
    # once { p children_id(left_sidebar) }
    # unless children_id(left_sidebar) == %w[sidebar-left-div]
    #   require'pry';binding.pry
    # end

    # content.children[0].children.reject(&BLANK).map_{ attr :id } == %w[sidebar-left table-main]

    # unless footer.text.strip == 'Copyright © 2005 - 2012 Dhamma Society - dhammasociety.org. email : worldtipitaka@dhammasociety.org'
    #   require'pry';binding.pry
    # end
    # body = body_tag #.children.reject { |x|%w[header footer content].include? x[:id]}
    # body.delete header
    # unless body.children.select{|x|x[:id]=='header'}.count == 0
    #   require'pry';binding.pry
    # end

    # unless children(body_tag).count == 3
    #   require'pry';binding.pry
    # end
    # return false unless children(body_tag).count == 3
    # return false
    # if 3 == navigation.keys.count
    #   require'pry';binding.pry
    # end

    # doc.at('head').remove
    # content.remove
    true
  end

  delegate :HTML, to: Nokogiri
end

def toc? element
  element.name == 'p' && 
   ["On Display : Title of Section Only","On Display : Table of Contents"].include?(element.text)
end

def wrap element
  if element[:class]
    klass = Nodes.const_get element[:class].capitalize
  else
    # raise p 'unknown element!!!' unless toc? element
    binding.pry unless toc? element
    klass = Nodes::Toc
  end
  klass.new element
end

module Logger
  def valid?
    valid = super
    unless valid
      require 'pry'; binding.pry
    end
    valid
  end
end

def wrap2 element
  klass_name = element[:class] || element.name
  klass = Nodes2.const_get klass_name.capitalize
  klass.new element
end

def wrap3 element
  klass_name = element[:class] || element.name
  klass = Nodes3.const_get klass_name.capitalize
  klass.new element
end

ELEMENTS_HAVE_ONLY_ONE_TEXT =->(elements) do
  elements.all? { |x| x.children.map(&:name) == ['text'] }
end  

module Nodes3
  class Paragraphnum < Struct.new :element
    def valid?
      ELEMENTS_HAVE_ONLY_ONE_TEXT[[element]]
    end
  end
  class Gatha < Struct.new :element
    def valid?
      ELEMENTS_HAVE_ONLY_ONE_TEXT[[element]]
    end
  end
  class Singlecolumn < Struct.new :element
    def valid?
      ELEMENTS_HAVE_ONLY_ONE_TEXT[[element]]
    end
  end  
end

module Nodes2

  ELEMENTS_HAS_ONLY_ONE_TEXT =->(elements) do
    elements.all? { |x| x.children.map(&:name) == ['text'] }
  end  

  # DIVNUMBERS_HAS_ONLY_ONE_TEXT =->(element) do
  #   element.children.select {|x|x[:class] == 'divNumber' }.all? { |x| x.children.map(&:name) == ['text'] }
  # end  

  # class Tr? < Struct.new :element
  #   def valid?;
  #     element.children.count == 0
  #   end
  # end


  class Td < Struct.new :element
    def valid?
      # ch = element.children.reject { |x| x.name == 'text' }
      # unless ch.map{|x|x[:class]} - %w[paragraphNum GATHA singleColumn] == []
      #   binding.pry
      # end
      ch.map{|x|x[:class]} - %w[paragraphNum GATHA singleColumn] == [] &&
          ch.map { |x| wrap3(x).extend(Logger) }.all_{ valid? }
      # true
    end
  end


  class Tr < Struct.new :element
    def valid?
      element.children.map(&:name) - ['td','text'] == []
    end
  end

  # tbody-tr  sv  tr
  class Tbody < Struct.new :element
    def valid?
      element.children.map(&:name) - ['tr'] == []
    end
  end


  class Singlecolumn < Struct.new :element
    def valid?
      ch = element.children.reject { |x| x.name == 'text' }
      ch.map(&:name) - ['tbody','tr','td'] == [] &&                     # crap with tr/td/tbody :)
          ch.map { |x| wrap2(x).extend(Logger) }.all_{ valid? }
    end
  end

  class Text < Struct.new :element
    def valid?
      element.children.count == 0
    end
  end
  class Divnumber < Struct.new :element
    def valid?
      # DIVNUMBERS_HAS_ONLY_ONE_TEXT[element]
      ELEMENTS_HAS_ONLY_ONE_TEXT[[element]]
    end
  end
  class Paragraph < Struct.new :element
    def valid?
      # p element.children.map{|x|x[:class]}
      # true
      ch = element.children.reject { |x| x.name == 'text' }
      (ch.map{|x|x[:class]} - %w[paragraphNum singleColumn smallFont italic bold]) == [] &&
          ELEMENTS_HAS_ONLY_ONE_TEXT[ch.reject{|x|x[:class]=='singleColumn'}] &&
          ch.select{|x|x[:class]=='singleColumn'}.map { |x| wrap2 x }.all_{ valid? }

    end
  end
  class Palisectionname < Struct.new :element
    def valid?
      ch = element.children.reject { |x| x.name == 'text' || x.name == 'br' }
      (ch.map{|x|x[:class]} - %w[paragraphNum]) == [] &&
         ELEMENTS_HAS_ONLY_ONE_TEXT[ch]
      #singleColumn smallFont italic bold]) == []
    end
  end
end

module Nodes
  module Kind
  end

  SPANS_HAS_ONLY_ONE_TEXT =->(element) do
    element.children.select_{ name == 'span' }.all? { |x| x.children.map(&:name) == ['text'] }
  end

  class Quotation < Struct.new :element; is Kind
    def valid?
      ((children_class(element) - ['paragraph','divNumber','paliSectionName']) == []) &&
          element.children.map { |x| wrap2(x).extend(Logger) }.all_{ valid? }
      # paliSectionName - seldom?
      # if children_class(element).include? 'paliSectionName'
      #   binding.pry
      # end
      # ((children_class(element) - ['paragraph','divNumber','paliSectionName']) == []) &&
      #        DIVNUMBERS_HAS_ONLY_ONE_TEXT[element]
      #&& element[:class] == 'paragraph'      
    end
  end
  class Toc < Struct.new :element; is Kind
    def valid?
      children(element) == ['text']
    end
  end
  class Hidden < Struct.new :element; is Kind
    def valid?;
      children(element) - ['text'] == []
    end
  end
  class Center < Struct.new :element; is Kind
    def valid?
      ((children(element) - ["span","text","br"]) == []) && SPANS_HAS_ONLY_ONE_TEXT[element]
      # && element.children.select_{ name=='span'}.all?{|x|children(x)==['text']} # or text + br
    end
  end
  class Endh3 < Struct.new :element; is Kind
    def valid?
      children(element) - ["span", "text", 'paragraphNum','br'] == [] && SPANS_HAS_ONLY_ONE_TEXT[element]
      ##################################################
      #paragraphNumparagraphNumparagraphNumparagraphNumparagraphNumparagraphNum
      ###################################################
    end
  end  
  class Summary < Struct.new :element; is Kind
    def valid?
      ((children(element) - ["span", "text"]) == []) && SPANS_HAS_ONLY_ONE_TEXT[element]
      #element.children.select_{ name=='span'}.all?{|x|children(x)==['text']}
    end
  end  
  class Endbook < Struct.new :element; is Kind
    def valid?
      children(element) == ["span", "text"] && SPANS_HAS_ONLY_ONE_TEXT[element]
    end
  end  
end



# they use bang version: children!
def children element
  element.children!.map(&:name)
end

def children_id element
  element.children!.map_{ attr :id }
end

def children_class element
  element.children!.map_{ attr :class }
end

def once
  if not $already_done
    yield
    $already_done = true
  end
end

def some_times
  yield if rand < 0.1
end

begin
  # pages = all_pages MAJJHIMA
  pages = all_pages FOUR_NIKAYAS+VINAYA
  p pages.count
  # page = pages.sample
  # raise unless page.is_a? FlatPage
  # pages.
  p pages.shuffle.all? &:valid? 

end #if false

# File.write 'random-page.html', page.html
# File.write 'random-page.yml', YAML.dump(page.doc.inspect)
# require'pry';binding.pry
# p tag pages.sample.content
# p pages.all? &x{ is_a? FlatPage }


collection = ALL
collection.shuffle.each { |selector|
  # puts (all_pages(selector).all?(&:valid?) ? '+':'-') + selector
  puts selector
  (all_pages(selector).all?(&:valid?)) ? nil : puts("---------------#{selector}")
} if false

# def how_long
#   t = Time.now
#   yield
#   p Time.now - t
# end
# how_long do pages.all? &:valid? end
# how_long do pages.all_{ valid? } end


BEGIN{
  module Model
    def self.included target
      target.send :include, ActiveAttr::Model
    end
  end
  class Module
    def is *others; include *others end
  end
  module IncludeAll
    def self.include? any; true end
  end  
  def x &block; proc { |obj| obj.instance_eval &block } end

  def all_pages filter=IncludeAll
    pages = WTP.get.only!(filter).parts.map { |part| part.pages.map { |p| {part: part, html: p.html} } }.flatten(1)
    pages.map { |x| FlatPage.new x }
  end
}
# p WTP.get.only!(MAJJHIMA).parts
# [DIGHA,MAJJHIMA,SAMYUTTA,ANGUTTARA].map do |group|
#   WTP.get.only!(group).parts.map { |x|x.pages.to_a }.flatten.count
# end.each do |x|
#   p x
# end
__END__
if __FILE__ == $0
  book = WTP.get.only! SAMYUTTA
  pages = book.parts.map { |x|x.pages.to_a }.flatten

  raise unless pages.count == 2117
  raise unless pages.all? &:valid?
  puts 'OK'
end


__END__
class Page
  def initialize data
    @doc = Nokogiri::HTML data
  end

  def extract
    { title: title, body: body, parent: parent }
  end

  def body
    whole = @doc.at('div#tipitakaBodyWrapper')
    whole.css('div.divNumber').remove
    whole.css('div.paragraphNum').remove
    whole.css('span.paragraphNum').remove
    whole.text
  end

  def title
    @doc.at('div#main h1.title').text
  end

  def parent
    @doc.css('div#main div.breadcrumb a')[-1].text
  end  
end

class Page
  
  def content
    doc.at 'div.content'
  end

  def doc
    @doc ||= doc!
  end
  def doc!
    Nokogiri::HTML html
  end

  def valid?
    @doc = nil
    doc.at('head').remove
    content.remove
    @doc = nil
    true
  end
end