# 1) validator:
#    - in memory representation?
#    - human readable validation code (kinda rspec)
#    - computer readable result of validation
# 2) extractor itself
#
# fuck memoization and other opt23n for now
# fuck Struct with its to_a
#
# modify selectors if classes ar stupid like a1 a2 a3...?
# remove scripts?

require 'my-sugar'
require_delegation
require 'nokogiri'
Dir['lib/*.rb'].each { |x| require_relative x }

require 'pp'
require 'pry'
load 'lib/test_helper'


measurements = %w"to_s text children.count".map { |x| Measurement[x] }


model = Extractor.new measurements
model.feed ''
pp model.state