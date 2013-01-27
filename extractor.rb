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

# tap_ &x

require 'my-sugar'
require_delegation
require_relative 'canon'
Dir['lib/*.rb'].each { |x| require_relative x }
require 'nokogiri'

require 'pp'
require 'pry'
load 'lib/test_helper'
require 'yaml'


def process model, pages
  pages.each do |page|
    Nokogiri::HTML(page).traverse do |node|
      model.feed node
    end
  end
  model.state
end


# class CaseNode < CommandRule
#   def act value, node
#     case value
#     when String

#     when Numeric
#     when Array
#     else
#       raise 'unknown type of value given!'
#     end
#   end
# end


[10].each do |i|
  model = Extractor { Compose *%w"to_s text children.count".map { |x| SimpleRule[x] }}
  data = process(model, WTP.pages(i))
  data = Hash[data.map{|k,v| [k, v.to_hash] }]
  File.write %'output#{i}.yml', YAML.dump(data)
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