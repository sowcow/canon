# <3 <3 <3 for plain ruby!
# <3 <3 <3 for plain ruby!
# <3 <3 <3 for plain ruby!

require 'nokogiri'

module Helpers
  def html page
    Nokogiri::HTML(page).at('html')
  end
  def extract_attributes node
    node.attributes.map { |k, v| [k, typecasted(v.value)] }
  end
  def typecasted(str) # to test?
    [str.to_i, str.to_f, str].find { |cast| cast.to_s.sub(?,,?.) == str.sub(?,,?.) }
  end  
end


module HTML_BIN

  class Page < Struct.new *%i[url other html]
    extend Helpers
    def self.[] given_html, url=nil, other={}
      root = Element[html given_html]
      new url, other, root
    end
  end

  class Element < Struct.new *%i[name text attributes children]
    extend Helpers
    def self.[] node
      attributes = extract_attributes(node).map { |pair| Attribute[*pair] }
      children = node.children.map { |x| Element[x] }
      new node.name, node.text, attributes, children
    end
  end

  class Attribute < Struct.new *%i[name value]
  end

end


if __FILE__ == $0
  include Helpers
  typecasted('0').class == Fixnum or raise
  typecasted('0.').class == String or raise
  typecasted('0.0').class == Float or raise
  
  include HTML_BIN
  TestHtml = '<div class=my>123</div><div class=my id=any></div>'
  Page[TestHtml].html.name == 'html' or raise
  Page[TestHtml].html.children.first.name == 'body' or raise
  Page[TestHtml].html.children.first.children.first.name == 'div' or raise
  Page[TestHtml].html.children.first.children.first.children.first.name == 'text' or raise
  Page[TestHtml].html.children.first.children.first.attributes.first.name == 'class' or raise
  Page[TestHtml].html.children.first.children.first.attributes.first.value == 'my' or raise

  Page[TestHtml].html.text == '123' or raise
  Page[TestHtml].html.children.first.children.first.children.first.text == '123' or raise

  Page[TestHtml].html.children.first.children[1].attributes[1].name == 'id' or raise
  Page[TestHtml].html.children.first.children[1].attributes[1].value == 'any' or raise

  puts :OK
end


__END__
# require 'active_record'
# require 'mini_record'
# require 'ancestry'
module Html2DB
  DATABASE = $split_db || 'temp-split.db'
  def self.database; DATABASE end

  # nice place for this:
  ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: database

  class Page < ActiveRecord::Base
    key :name
    key :other; serialize :other, Hash 
    has_many :elements
  end
  class Element < ActiveRecord::Base
    key :name
    belongs_to :page
    has_many :attributes
    has_ancestry; key :ancestry; index :ancestry
  end
  class Attribute < ActiveRecord::Base
    key :name
    key :value
    belongs_to :element
  end

  def self.models
    constants.map { |x| const_get x }.
              select { |x| x.is_a?(Class) && x.superclass == ActiveRecord::Base }   
  end
  def self.clear
    conn = ActiveRecord::Base.connection
    # to catch sqlite_sequence table when exist...
    tables = conn.execute("SELECT * FROM sqlite_master WHERE type='table'").map{|x|x['name']}
    tables.each { |t| conn.execute("DELETE FROM #{t}") } 
  end
  def self.migrate
    models.each &:auto_upgrade!
  end
  def self.renew
    clear; migrate
  end

  include Helpers

  def feed_page given_html, name=nil, other={}
    Page.transaction do
      page = Page.create name: name, other: other
      process page, html(given_html)
    end
  end

  def process page, parent_element=nil, node
    element = page.elements.create(name: node.name, parent: parent_element)
    extract_attributes(node).each do |name, value|
      element.attributes.create name: name, value: value
    end
    node.children.each do |child|
      process page, element, child
    end
  end

  def feed_pages pages, output, pages_per_transaction=50
    Html2DB.renew
    pages.each_slice(pages_per_transaction).each do |pages|
      Page.transaction do
        pages.each { |x| feed_page *x }
      end
      print '+' # yield?
    end
    File.rename Html2DB.database, output
  end
end

# Html2DB.migrate # ?

if __FILE__ == $0
  include Html2DB

  Html2DB.renew
  [Page,Element,Attribute].map(&:count) == [0,0,0] or raise
  feed_page '<div></div>'
  [Page,Element,Attribute].map(&:count) == [1,3,0] or raise
  Element.all.map(&:id) == [1,2,3] or raise

  Html2DB.renew
  [Page,Element,Attribute].map(&:count) == [0,0,0] or raise
  feed_page '<div></div>'
  [Page,Element,Attribute].map(&:count) == [1,3,0] or raise
  Element.all.map(&:id) == [1,2,3] or raise

  feed_page '<div></div>'
  [Page,Element,Attribute].map(&:count) == [2,6,0] or raise

  feed_page '<div class=any></div>'
  [Page,Element,Attribute].map(&:count) == [3,9,1] or raise

  feed_page '<div class=any other=other></div>'
  [Page,Element,Attribute].map(&:count) == [4,12,3] or raise

  Attribute.all.map(&:name) == %w[class class other] or raise
  Attribute.all.map(&:value) == %w[any any other] or raise
  Attribute.all.map { |x| x.element.page.id } #== [3,4,4] or raise

  Page.all.map(&:name) == 4.times.map{ nil } or raise
  Page.all.map(&:other) == 4.times.map{ {} } or raise
  Page.all.map { |x| x.elements.count } == 4.times.map{ 3 } or raise

  Element.all.map(&:name) == 4.times.map{ %w[html body div] }.flatten or raise
  Element.all.map { |x| x.page.id } == 4.times.map{ |i| 3.times.map{ i+1 } }.flatten or raise

  TEMP = 'any.db'
  feed_pages ['<div></div>'], TEMP
  [Page,Element,Attribute].map(&:count) == [1,3,0] or raise  
  File.exist? TEMP or raise
  File.delete TEMP

#Html2DB.database
=begin
  class Element < ActiveRecord::Base
    key :name
    belongs_to :page    
    has_many :attributes
    has_ancestry; key :ancestry
  end
=end
  # raise unless Value.create(value: 123).value == 123
  # raise unless Attribute.create(name: 'class', values:[Value.create(value: 123)]).name == 'class'
  # raise unless Attribute.create(name: 'class', values:[Value.create(value: 123)]).values.first.value == 123
  # raise unless Element.create(selector: 'html > body', attributes:[Attribute.create(name: 'class')]).attributes.first.name == 'class'
  # raise unless Element.create(selector: 'html > body', attributes:[Attribute.create(name: 'class')]).selector == 'html > body'
  puts :OK
end
