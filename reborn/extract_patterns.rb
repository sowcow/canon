Dir.chdir '..'
require './lib/file_works'
require './lib/patterns'
require 'moneta'
require 'yaml'
# [selector, attribute] - pair key ?

END{
  def extract input, output
    rm output
    result = extract_patterns Moneta.new(:LevelDB, :dir => input), {}
    File.write output, YAML.dump(result) # [Finished in 19.7s]
                     # Moneta.new(:Sqlite, :file => output)       # [Finished in 21.7s]
                     # Moneta.new(:YAML, :file => output)         # [Finished in 173.9s]
                     # Moneta.new(:LevelDB, :dir => output+'.db') # [Finished in 18.8s]
  end
  def extract_digha
    extract 'reborn/digha', 'reborn/digha-patterns.yml'
  end
  def extract_majjhima
    extract 'reborn/majjhima', 'reborn/majjhima-patterns.yml'
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




























__END__
Dir.chdir '..'
require './lib/html'
include HTML
require './lib/selector'
require './canon'
require 'moneta'
require 'progress'

END{
  pages = WTP.all_pages # WTP.get.only!(DIGHA).all_pages

  htmls = pages.map { |x| x[:html] }
  # show_selectors htmls, 'reborn/selectors.txt'
  # feed htmls, Moneta.new(:LevelDB, :dir => 'reborn/digha') #:file => 'reborn/selectors.db')
  feed htmls, Moneta.new(:LevelDB, :dir => 'reborn/selectors')
}
# 245.8s - only split - all
# HashFile: 4285.0s 9.8Mb

# redefine them and return nil to filter crappy classes or ids with numeration
class Selector
  # def klass; node[:class] =~ /\d/ ? (warn node[:class];nil) : node[:class] end
  # ENDH3  not so often! #/\d/
  # OK_CLASS
  # def klass; node[:class] =~ /\d/ ? (warn node[:class];nil) : node[:class] end

  # YES - handy work! 
  ODD_ID = /^([ph]_\d.*\d)|(block-tipitaka-\d+)|(block-user-\d+)|(block-block-\d+)$/
  # def id; node[:id] =~ ODD_ID ? nil : (node[:id] =~ /\d/ ? (warn(node[:id]);node[:id]) : node[:id]) end
  # faster?:
  def id; (given = node[:id]) =~ ODD_ID ? nil : given end
end

def selector node; Selector[node].to_s end

def show_selectors htmls, output, count = 50
  all_selectors = htmls.sample(count).map do |html|
    split(html).map { |node| selector(node) }
  end.flatten.uniq.sort_by &:size
  File.write output, all_selectors.join(?\n)
end

def feed htmls, store

  Progress('Processing pages', htmls.size) do

  htmls.each do |html|; Progress.step(1)
    split(html).each do |node|
      selector = selector(node)
      unless store.key? selector
        store[selector] = {}
        store[:tables] = [] unless store.key? :tables
        store[:tables] << selector
      end

      attributes = store[selector]
      attributes(node).each do |attribute,value| # << tag_name, text, to_html !

        attributes[attribute] = [] unless attributes[attribute]
        attributes[attribute] << value

      end
      store[selector] = attributes
    end
    # store.adapter.backend.compact
  end

  store.close  

  end # Progress
end