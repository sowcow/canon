# 1) validator:
#    - in memory representation?
#    - human readable validation code (kinda rspec)
#    - computer readable result of validation
# 2) extractor itself
#
# fuck memoization and other opt23n for now
# fuck Struct with its to_a
#
# modify selectors if classes ar stupid like a1 a2 a3...?!!!!!!!! or ids!!!!
# remove scripts?
# element exist on all pages?
# different selectors?
# attributes
# regexp_for if length < 1000 ?
# do not traverse nodes where "..."
# >1 passes 1st: delete all text ~ same
# on all pages?
# [:class/:id] if =~ /d/
# recursive ul > li

# <li class="leaf" nid="271056"

# tap_ &x


   # {"children_ids"=>#<Set: {[], [nil]}>},
   # {:attributes=>
   # children: { count: 0 } or { count: 1, ids: [] ...}
   # { not only regexp, but examples too or edge cases, all combinations using db? }
   # generates not a spec but Struct/Model with invariants that mostly needed to reject unused structs
   # class ...; PATH = /^div > ...$/ end
   # 1:1

require 'my-sugar'
#require_delegation
require_relative 'canon'
Dir['lib/*.rb'].each { |x| require_relative x }
require 'nokogiri'

require 'pp'
require 'pry'
load 'lib/test_helper'
require 'yaml'


def process model, pages
  pages.each do |page|
    Nokogiri::HTML(page).at('html').traverse do |node|
      model.feed node
    end
  end
  model.state
end

class Nokogiri::XML::Node
  def children_tags
    children.map &:name
  end
  def children_classes
    children.map &x{ self[:class] }
  end
  def children_ids
    children.map &x{ self[:id] }
  end
  # def children_count
  #   children.count
  # end  
  # alias html to_html
  # def text
  #   super.to_s
  # end
end

# AttributesRule = Rule
# MEASUREMENTS = %w"to_html text.to_s children.count children_tags children_classes children_ids" +
#                [AttributesRule]

measurements = -> do
 Compose(*%w"to_html.size  to_html  text.to_s.size  text.to_s 
             children.count children_tags children_classes children_ids".map { |x| FlexibleRule[x] } + 
             [AttributesRule.new])
end

# psych have problems with '123.'
# YAML::ENGINE.yamler = 'syck'

# [1,50,100,500].each do |i|
['all'].each do |i|
  model = Extractor &measurements # { Compose *MEASUREMENTS.map { |x| FlexibleRule[x] }}
  pages = WTP.all_pages #(i)
  data = process(model, pages)
  data = Hash[data.map{|k,v| [k, v.to_hash] }]
  # File.write %'output#{i}.yml', YAML.dump(data)
  require 'pp'; PP.pp(data,File.open("output_#{i}.txt",'wt'))
  require 'yaml'; File.write("output_#{i}.yml", YAML.dump(data))
  p "finished: #{i}"
end

# model = Extractor.new measurements
# model.feed ''
# pp model.state
# model.feed '1'
# pp model.state
# model.feed '2'
# pp model.state
# model.feed '<p>2<b>3</b></p>'
# pp model.state
