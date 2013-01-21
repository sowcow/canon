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

require 'my-sugar'
require_delegation
require_relative 'canon'
Dir['lib/*.rb'].each { |x| require_relative x }

require 'pp'
require 'pry'
load 'lib/test_helper'
require 'yaml'



measurements = %w"to_s text children.count".map { |x| Measurement[x] }

model = Extractor.new measurements
pages(1000).each do |page|
  model.feed page
end
File.write 'output.yml', YAML.dump(model.state)

# model = Extractor.new measurements
# model.feed ''
# pp model.state
# model.feed '1'
# pp model.state
# model.feed '2'
# pp model.state
# model.feed '<p>2<b>3</b></p>'
# pp model.state

BEGIN{
  def pages count
    WTP.get.parts.map_{ pages.map &:html }.flatten.sample(count)
  end
}