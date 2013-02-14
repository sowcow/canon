require_relative './split/html_2_bin'
require_relative './group/all'
require_relative './lib/awesome_marshaling'
require_relative './lib/external_sort'
include CollectionFile
require_relative './lib/struct_builder'

# ?[Finished in 1771.6s]
# ?4GB
# [Finished in 8743.5s]
# less than pages.bin

module Model
  # *%i[url other] #html
  class FlatElement < Struct.new *(%i[name text attributes parent] + %i[page children_info selector]) #children
    extend StructBuilder
  end
  # class Attribute < Struct.new *%i[name value]
  # end
end

Dir.chdir project = 'mini'


if File.exist? 'temp-grouped.bin'
  GroupSorted Load('temp-grouped.bin'), 'grouped.bin' do |x|
    x.selector
  end
else
  Group 'elements.bin', 'grouped.bin', 50000 do |x|
    x.selector
  end
end

__END__
def recurse_children element
  [element, element.children.map { |x| recurse_children x }]
end

def attributes givens, name
  givens.map { |x| a = x.attributes.find{|a|a.name == name}; a.nil?? nil : a.value }
end

MapArray 'pages.bin', 'elements.bin' do |page|
  # elements = []

  recurse_children(page.html).flatten.map  { |prev| Model::FlatElement.on_top_of(prev, {page: {url: page.url, other: page.other}, children_info: {count: prev.children.count, names: attributes(prev.children,:name), classes: attributes(prev.children,:class), ids: attributes(prev.children,:id)} }) }

  # Element.page.keys == %i[url other]
  # Element.children_info.keys == %i[count names classes ids]

  # elements  

end

__END__
# require './group/all'
# # include GroupPages

# group 'html-in.db', 'grouped.db'

require 'msgpack'
# deserialize objects from an IO
def process_each file, &process
  $count = 0
  MessagePack::Unpacker.new(File.open(file)).each do |str|#; obj = Marshal.load(str)
    $count += 1
    #p obj.name
  end
rescue
  puts $count
end

process_each 'pages.bin' do

end