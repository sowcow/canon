#encoding: utf-8
require_relative 'canon'
require 'my-sugar'
require_delegation

require 'active_attr'
require 'nokogiri'

# THIS WAY FOR NOW: extracting invariants like: the pages has only one header
# alternative: (all nodes ~> those who unchanged? ~> those who are stupid/unused info ~> result!!!)

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
    # clean_state!
    true
  end

  delegate :HTML, to: Nokogiri
end

# def clean_state!; @doc = nil end

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

begin
  pages = all_pages MAJJHIMA
  # pages = all_pages FOUR_NIKAYAS
  p pages.count
  page = pages.sample
  raise unless page.is_a? FlatPage

  p pages.all? &:valid? 

end #if false

# File.write 'random-page.html', page.html
# File.write 'random-page.yml', YAML.dump(page.doc.inspect)
# require'pry';binding.pry
# p tag pages.sample.content
# p pages.all? &x{ is_a? FlatPage }


collection = ALL
collection.each { |selector|
  puts (all_pages(selector).all?(&:valid?) ? '+':'-') + selector
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