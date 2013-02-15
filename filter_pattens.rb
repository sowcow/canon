require 'yaml'
require 'set'
require 'moneta'
require 'ruby-progressbar'
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

RESULT = 'output/majjhima-filtered.yml'
ALL_VALUES = Moneta.new :LevelDB, dir: 'output/majjhima'
data = PatternData['output/majjhima-patterns.yml']
puts 'wtf?' unless data.valid?
data = data.to_h


require "highline/system_extensions"
# include HighLine::SystemExtensions
def one_char prompt
  print prompt
  HighLine::SystemExtensions.raw_no_echo_mode; result = HighLine::SystemExtensions.get_character; HighLine::SystemExtensions.restore_mode;
  result.chr  
end

def clear; system 'clear' end #print "\e[H\e[2J" end

# print "Press any key:"
# k = one_char #get_character
# puts k.chr
# exit 0
def min_info key, value, full_attribute
  clear
  puts "selector: #{key}"
  value.each_pair do |k,v|
    # v = case v
    #     when Set then "Set[]"
    #     end
    puts
    puts "#{k}   #{v.inspect}"
  end

  if full_attribute
    puts
    max_info key, value, value.keys[full_attribute]
  end
  # puts value
end

def max_info key, value, attribute
  # p key
  # clear
  puts "#{attribute}:"
  # puts
  values = ALL_VALUES[key]
  puts attribute = values[attribute].inspect[0..5000] #.find { |x,y| x == attribute }[1]
  # system %'echo "#{attribute}" | less'
  # value.keys.each do |attribute|
  # end
  # system %'echo "#{value[:text].to_s}" | less'
end



trash_data = []
useful_data = []
full_attribute = nil

# whole = data.each_pair.count
# current = 1
progress = ProgressBar.create format: '%a %e [%B] %p%%', total: data.each_pair.count

data.each_pair do |key,value|
  @key, @value = key, value

  # $><<">> ";
  min_info key, value, full_attribute
  # clear
  # puts "selector: #{key}"
  puts
  progress.increment
  puts
  # puts "#{current} of #{whole}"
  # puts
  # puts '(qQ ~ quit | oO ~ ok | tT ~ trash | + ~ inspect)'
  case char = one_char('>> ')
  when /q|Q/ then break
  when /h|H|\?|\// then puts '(qQ ~ quit | oO ~ ok | tT ~ trash | + ~ inspect) [Press enter]';sleep 2;redo
  when /o|O/ then useful_data << [key,value]
  when /t|T/ then trash_data << [key,value]
  when '+' then full_attribute ||= 0; full_attribute += 1; redo
  when '-' then full_attribute ||= 0; full_attribute -= 1; redo
  else 
    redo
    # puts "unknown command: #{char}";sleep 2;redo
  end
  full_attribute = nil
  
  # ;$><<'=> ';p eval$_
end

File.write RESULT, YAML.dump({useful: useful_data, other: trash_data})
# clear

__END__
require 'readline'
loop do
  line = Readline::readline('> ')
  break if line.nil? || line == 'quit'
  Readline::HISTORY.push(line)
  puts "You typed: #{line}"
end
__END__
require 'ripl'
# Define plugins, load files, etc...
useful_data = {}
crap_data = {}

def ok
end

data.each_pair do |key,value|
  @key, @value = key, value
  # Ripl.start
  $><<">> ";gets;$><<'=> ';p eval$_
end


# p data.to_a.first
