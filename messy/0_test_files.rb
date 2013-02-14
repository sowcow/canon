require_relative './lib/awesome_marshaling'
require_relative './split/html_2_bin'
include CollectionFile

p Load('pages.bin').take(1)
# p Load('mini/grouped.bin').take(1)
# p Load('pages.bin').count
# 20108
# [Finished in 91.2s]



__END__
puts "preparing data..."
pages = WTP.pages.map { |x| [x[:html], nil, {part: x[:part]}] }

puts "processing + saving data..."
save_map 'pages.bin', pages, 1000 do |page|
  HTML_BIN::Page[*page]
end


__END__
require 'msgpack'

def save_map file, elements, chunk_size=100, &process
  pk = MessagePack::Packer.new(File.open(file,'wb'))
  pk.write_array_header(elements.size)
  elements.each_slice(chunk_size) do |group|
    group.each { |x| pk.write Marshal.dump process.call(x) }
    pk.flush
  end
end


puts "preparing data..."
pages = WTP.pages.map { |x| [x[:html], nil, {part: x[:part]}] }

puts "processing + saving data..."
save_map 'pages.bin', pages, 1000 do |page|
  HTML_BIN::Page[*page]
end




=begin
puts "preparing..."
pages = WTP.pages.map { |x| [x[:html], nil, {part: x[:part]}] }

puts "processing..."
data = pages.map { |x| HTML_BIN::Page[*x] }

puts "writing..."
File.write 'pages.bin', data
=end


__END__



__END__

# require './split/all'
# require './canon'
# include Html2DB

# pages = WTP.pages.first(5).map { |x| [x[:html], {part: x[:part]}] }

# feed_pages pages, 'test-speed.db'