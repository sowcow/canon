require 'yaml'
require 'set'
require './lib/model'

class PatternData; is Model(:file, data: nil)
  def initialize(*);super
    @data = YAML.load File.read file
  end
  def valid?
    tables = data[:tables]
    tables.all? { |exist| data.key? exist } && data.keys.count == tables.count + 1 && ! to_h.key?(:table)
  end
  def to_h
    data.dup.tap { |x| x.delete :tables }
  end
end


data = PatternData['output/majjhima-patterns.yml']
puts 'wtf?' unless data.valid?
p data.to_h.keys.count
















