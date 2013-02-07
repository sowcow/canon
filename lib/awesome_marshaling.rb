def Load file
  Enumerator.new do |out|
    File.open file do |f|
      out.yield Marshal.load f while not f.eof?
    end  
  end
end

class MySweetSaver < BasicObject
  def initialize file, &block; @file, @block = file, block end
  def << element; @block.call element end 
end

def Save file
  f = File.open file, 'w' do |io|
    yield MySweetSaver.new(file) { |obj| Marshal.dump obj, io }
  end    
end

def Map input, output
  Save output do |file|
    Load(input).each { |o| file << yield(o) }
  end
end

if __FILE__ == $0
  
  def delete file; File.delete file if File.exist? file end
  file = 'test-marshal.bin'
  delete file

  Save file do |file|
    (1..3).each { |i| file << i }
  end

  Load(file).to_a == [*1..3] or raise


  BIG1 = 'test-marshal-big1.bin'
  BIG2 = 'test-marshal-big2.bin'
  BIG3 = 'test-marshal-big3.bin'
  [BIG1,BIG2,BIG3].each &method(:delete)


  Save BIG1 do |file|
    (1..1000).each { |i| file << i }
  end

  Save BIG2 do |file|
    Load(BIG1).each { |i| file << "~#{i}~"}
  end

  Map(BIG2, BIG3) do |obj|
    obj + '!!!'
  end

  Load(BIG1).take(10) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] or raise
  Load(BIG2).take(5) == ["~1~", "~2~", "~3~", "~4~", "~5~"] or raise
  Load(BIG3).take(3) == ["~1~!!!", "~2~!!!", "~3~!!!"] or raise

  puts :OK # all tests succeed 
end