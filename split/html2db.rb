require './db_adapter'
require 'nokogiri'
require '../lib/selector'

module Html2DB
class << self

  def split pages, attributes, database
    renew

    pages.each do |page|
      nodes(page).each do |node|
        element = Element.where(selector: selector(node)).first_or_create
        attributes.each do |scan|
          attribute = element.attributes.where(name: scan.name).first_or_create
          attribute.values.where(value: scan.process[node]).create
            # << Value.create(value: attribute_type.value(node))
        end      
      end
    end

    File.rename DATABASE, database
  end

  def selector node
    Selector[node].to_s
  end

  def nodes page
    [].tap do |result|
      Nokogiri::HTML(page).at('html').traverse do |node|
        result << node
      end
    end
  end

end  
end


# scans = rules = attributes = measurements...
if __FILE__ == $0
  require 'sequel'
  TEMP = 'temp-test.db'
  TestScan = Struct.new :name, :process

  pages = ['<div any=cool>123</div>',
           '<div any=other>123</div>']
  scans = [TestScan['class', ->(x){ x.attr :any }]]
  Html2DB.split pages, scans, TEMP

  db = Sequel.sqlite TEMP
  raise unless db[:elements].all ==
    [{:id=>1, :selector=>"document > html > body > div > text"},
     {:id=>2, :selector=>"document > html > body > div"},
     {:id=>3, :selector=>"document > html > body"},
     {:id=>4, :selector=>"document > html"}]

  raise unless db[:attributes].all == 
    [{:id=>1, :name=>"class", :element_id=>1},
     {:id=>2, :name=>"class", :element_id=>2},
     {:id=>3, :name=>"class", :element_id=>3},
     {:id=>4, :name=>"class", :element_id=>4}]
     
  # p db[:values].all     
  # raise unless db[:values].all == 
  #   [{:id=>1, :value=>nil, :attribute_id=>1},
  #    {:id=>2, :value=>"cool", :attribute_id=>2},
  #    {:id=>3, :value=>nil, :attribute_id=>3},
  #    {:id=>4, :value=>nil, :attribute_id=>4},
  #    {:id=>5, :value=>nil, :attribute_id=>1},
  #    {:id=>6, :value=>"other", :attribute_id=>2},
  #    {:id=>7, :value=>nil, :attribute_id=>3},
  #    {:id=>8, :value=>nil, :attribute_id=>4}]

  File.delete TEMP
  puts :OK
end