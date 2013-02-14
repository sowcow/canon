require 'forwardable'
require 'zlib'   # if installed? in code too?
# require 'snappy' # if installed? in code too?
# packed item, lazy unpacking

module CollectionFile

  class Marshaler
    extend Forwardable
    def_delegators :Marshal, :dump, :load
  end

  class Processor < Marshaler
    def self.[] *a,&b; new *a,&b end
    def initialize processor
      @processor = processor
    end
    def load io
      Marshal.load @processor.inflate super
    end
    def dump obj,io
      super @processor.deflate(Marshal.dump(obj)), io
    end
  end

  MARSHAL = Marshaler.new
  # SNAP = Processor[Snappy]
  ZIP = Processor[Zlib]

  DEFAULT = ZIP

  class MySweetSaver < BasicObject
    def initialize file, &block; @file, @block = file, block end
    def << element; @block.call element end 
  end

  def Load file, processor=DEFAULT
    Enumerator.new do |out|
      File.open file do |io|
        out.yield processor.load io while not io.eof?
      end  
    end
  end

  def Save file, processor=DEFAULT
    f = File.open file, 'w' do |io|
      yield MySweetSaver.new(file) { |obj| processor.dump obj,io }
    end    
  end

  def Map input, output, processor=DEFAULT
    Save output,processor do |file|
      Load(input,processor).each { |o| file << yield(o) }
    end
  end

  # or explicit output << [1,2,3] if arity == 2 : too many sugar?
  def MapArray input, output, processor=DEFAULT
    Save output,processor do |file|
      Load(input,processor).each { |o| yield(o).each { |x| file << x } }
    end
  end  

end

if __FILE__ == $0
  include CollectionFile

  [MARSHAL,ZIP,DEFAULT].each do |xxx| # optional param  #SNAP
  
    def delete file; File.delete file if File.exist? file end
    file = 'test-marshal.bin'
    delete file

    Save file,xxx do |file|
      (1..3).each { |i| file << i }
    end

    Load(file,xxx).to_a == [*1..3] or raise
    a = Load(file,xxx)
    a.peek == 1 or raise
    a.peek == 1 or raise
    a.next == 1 or raise
    a.peek == 2 or raise


    big1 = 'test-marshal-big1.bin'
    big2 = 'test-marshal-big2.bin'
    big3 = 'test-marshal-big3.bin'
    big4 = 'test-marshal-big4.bin'
    [big1,big2,big3,big4].each &method(:delete)


    Save big1,xxx do |file|
      (1..100).each { |i| file << i }
    end

    Save big2,xxx do |file|
      Load(big1,xxx).each { |i| file << "~#{i}~"}
    end

    Map(big2, big3,xxx) do |obj|
      obj + '!!!'
    end

    def odd(i); i % 2 == 1 end
    odd(3) or raise 

    MapArray(big1, big4,xxx) do |obj|
      odd(obj) ? [] : (1..[4,obj].min).map { obj } # none or several
    end  

    Load(big1,xxx).take(10) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] or raise
    Load(big2,xxx).take(5) == ["~1~", "~2~", "~3~", "~4~", "~5~"] or raise
    Load(big3,xxx).take(3) == ["~1~!!!", "~2~!!!", "~3~!!!"] or raise
    Load(big4,xxx).take(7) == [2, 2, 4, 4, 4, 4, 6] or raise

    [file,big1,big2,big3,big4].each &method(:delete)

  end

  puts :OK # all tests succeed 
end