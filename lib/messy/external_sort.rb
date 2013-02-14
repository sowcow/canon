require_relative 'awesome_marshaling'
require 'fileutils'
class Enumerator
  # take + seek
  def take_next how_many
    result = []
    how_many.times.map { result << self.next }
    result
  rescue StopIteration
    result
  end

  def eof?
    peek
    false
  rescue StopIteration
    true
  end  
end

module CollectionFile

  # processor=DEFAULT - everywhere!!!

  extend Forwardable
  def_delegators :FileUtils, :mkpath, :rm_r
  def_delegators :File, :join, :rename

  def next_file dir, template='file_%f'
    mkpath dir unless Dir.exist? dir
    begin name = template % rand end while File.exist? name
    name = join dir, name
    File.write name, ''
    name
  end

  def chop_and_sort input, dir, chunk_size, processor=DEFAULT, &by
    source = Load(input,processor)
    while not (chunk = source.take_next(chunk_size)).empty? do
      Save next_file(dir), processor do |f|
        chunk.sort_by(&by).each { |x| f << x }
      end
    end
  end

  def merge_sorted dir, result, processor=DEFAULT, &by
    chunks = Dir[join dir, '*'].map { |x| Load(x,processor) }
    Save result,processor do |f|
      while not chunks.all? &:eof?
        min = chunks.map(&:peek).min_by &by
        chunks.find { |x| x.peek == min }.next
        f << min
        chunks.reject! &:eof?
      end
    end
  end

  def Sort input, output, chunk_size, processor=DEFAULT, &by
    mkpath temp = "temp"
    rm_r temp
    mkpath temp # untested

    chunks_dir = join(temp,'sorted_chunks')

    chop_and_sort input, chunks_dir, chunk_size, processor, &by
    merge_sorted chunks_dir, output, &by

    rm_r 'temp'
  end

  def GroupSorted sorted, output, processor=DEFAULT, &key
    group_key = :something_even_more_unique_than_nil
    group = []

    Save(output,processor) do |output|
      sorted.each do |object|
        if key[object] == group_key
          group << object
        else
          output << [group_key, group] unless group.empty?
          group = []
          group_key = key[object]
          group << object
        end
      end
      output << [group_key, group] unless group.empty?
    end    
  end

  def Group input, output, chunk_size, processor=DEFAULT, &key
    temp = "temp-#{output}"
    Sort input, temp, chunk_size, processor, &key
    sorted = Load(temp,processor)

    GroupSorted sorted, output, processor, &key
  end
end


if __FILE__ == $0

  a = [1,2,3].to_enum
  a.take_next(2) == [1,2] or raise
  a.take_next(2) == [3] or raise
  a.take_next(2) == [] or raise

  # exit
  include CollectionFile
  temp = Hash.new { |h,i| h[i] = "temp_#{i}"}

  count = rand(1..10)
  data = [*1..count].shuffle
  Save temp[1] do |f|
    data.each { |i| f << i }
  end

  chunk_size = rand(1..20)
  rm_r 'temp' if Dir.exist? 'temp'
  mkpath 'temp'

  chop_and_sort temp[1], 'temp_chunks', chunk_size do |x| x end
  chunk_files = Dir['temp_chunks/*'].select { |x| not File.directory? x }
  chunk_files.count == (count.to_f/chunk_size).ceil or raise
  chunk_files.all? { |x| arr = Load(x).to_a; arr == arr.sort } or raise

  merge_sorted 'temp_chunks', temp[5] do |x| x end
  File.exist? temp[5] or raise
  Load(temp[5]).to_a == data.sort or raise
  rm_r 'temp_chunks'

  temp.values.each { |x| File.delete x if File.exist? x }

  Save temp[1] do |f| (-10..10).to_a.shuffle.each { |i| f << i } end
  Sort temp[1],temp[2],2 do |x| x end
  File.exist? temp[2] or raise
  Load(temp[2]).count == Load(temp[1]).count or raise
  Load(temp[2]).to_a == Load(temp[1]).sort or raise

  Dir.exist?('temp') == false or raise

  temp.values.each { |x| File.delete x if File.exist? x }

  data = 20.times.map { rand 1..5 } 
  Save temp[1] do |f| data.each { |x| f << x } end
  Group temp[1], temp[2], 10 do |x| x end
  Load(temp[2]).to_a.map { |x| x[:group] }.flatten == data.sort or raise
  Load(temp[2]).to_a.all? { |x| key = x[:key]; x[:group].all? { |x| x == key }} or raise

  temp.values.each { |x| File.delete x if File.exist? x }
  puts :OK
end