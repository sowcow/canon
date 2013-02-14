require_relative 'lib/file_works'
require_relative 'lib/patterns'
require 'moneta'
require 'yaml'

# store as (selector, attribute = pair key) - (value) ?

END{
  def extract input, output
    rm output
    result = extract_patterns Moneta.new(:LevelDB, :dir => input), {}
    File.write output, YAML.dump(result)
  end
  def extract_digha
    extract 'output/digha', 'output/digha-patterns.yml'
  end
  def extract_majjhima
    extract 'output/majjhima', 'output/majjhima-patterns.yml'
  end  

  extract_majjhima
}

def push store, key, value
  store[key] = [] unless store.key? key
  store[key] = store[key] << value # ...
end

def default store, key, default
  store[key] = default unless store.key? key
end

def extract_patterns input, output
  input[:tables].each do |selector|
    push output, :tables, selector
    default output, selector, {}

    attributes = output[selector]
    input[selector].each_pair do |attribute, values|
      raise 'wtf!' if attributes.key? attribute

      attributes[attribute] = pattern(values)
    end  
    output[selector] = attributes
  end
  output
end

def pattern values
  PatternExtractors.extract_pattern *values
end