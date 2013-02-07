require_relative './split/html_2_bin'
require_relative './group/all'
require_relative './lib/awesome_marshaling'

# Map 'pages.bin', 'grouped.bin' do |page|
# end

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