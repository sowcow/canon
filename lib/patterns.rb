require_relative 'model'
require 'set'

# RegexpExtractor ~ dup? to prevent side effects?

module PatternExtractors
  extend self

  class Extractor; is Model(:values)
    PRIORITY = 0  
    def self.accept? values
      false
    end
  end


  class ExactlyExtractor < Extractor
    PRIORITY = 99
    def self.accept? values
      values.all? { |x| x == values.first }
    end
    def extract
      values.first
    end
  end

  class SetExtractor < Extractor
    PRIORITY = 88
    MAX_SET = 10
    def self.accept? values
      values.uniq.count <= MAX_SET
    end
    def extract
      Set[*values]
    end
  end

  # for Array
  class FlattenExtractor < Extractor
    def self.accept? values
      values.all_{ is_a? Array }
    end
    def extract
      {flatten: PatternExtractors.extract_pattern(*values.flatten(1))}
    end
  end

  # for Numeric
  class RangeExtractor < Extractor
    def self.accept? values
      values.all_{ is_a? Numeric }
    end
    def extract
      (values.min..values.max)
    end
  end

  # for String
  class RegexpExtractor < Extractor
    def self.accept? values
      values.all_{ is_a? String }
    end
    def extract
      head, tail = head_tail values.map &:chars
      /^#{Regexp.escape head}.*#{Regexp.escape tail}$/m
    end

    private
    def head_tail chars
      head = take_same chars
      chars.each { |x| x.shift head.size }
      chars = chars.map &:reverse
      tail = take_same chars
      [head, tail.reverse]
    end  
    def take_same chars
      (chars[0].zip(*chars[1..-1]).take_while { |row| (first = row.first) != nil && row.all? { |x| x == first } }.transpose.first || []).join
    end
  end     

  # next try without nils
  class WithNilsExtractor < Extractor
    PRIORITY = -10    
    def self.accept? values
      values.compact.all_{ is_a? values.first.class }
    end
    def extract
      {with_nil: PatternExtractors.extract_pattern(*values.compact)}
    end
  end  

  def extractors
    PatternExtractors.constants.map { |x| PatternExtractors.const_get(x) }.select { |x| x.is_a?(Class) && x < Extractor && x != Extractor }
  end

  def find_extractor values
    found = extractors.sort_by { |x| -x::PRIORITY }.find { |x| x.accept? values }
    # raise "found #{found.count} extractors!" unless found.count == 1
    # found.first
  end

  def extract_pattern *values
    values = [*values].uniq
    type = find_extractor(values)
    p values unless type
    type.new(values).extract
  end
end


if __FILE__ == $0
  include PatternExtractors

  PatternExtractors.extract_pattern(1,1,1) == 1 or raise
  extract_pattern(1,1,1) == 1 or raise
  extract_pattern(1,2,2,1,1,2) == Set[1,2] or raise
  extract_pattern(1,'a',[1,2,3]) == Set[1,'a',[1,2,3]] or raise
  extract_pattern(*-10..10) == (-10..10) or raise

  extract_pattern([1,2],[1,2]) == [1,2] or raise
  extract_pattern([1,2],[1,3]) == Set[[1,2],[1,3]] or raise
  extract_pattern(*11.times.map { |i| i.times.map{ 1 }}) == {flatten: 1} or raise
  extract_pattern(*11.times.map { |i| i.times.map{1}+i.times.map{2} }) == {flatten: Set[1,2]} or raise

  RegexpExtractor.new(%w[aaaaabbbbb aaaabbbb]).extract == /^aaaa.*bbbb$/m or raise
  RegexpExtractor.new(%w[lloo llxoo]).extract ==/^ll.*oo$/m or raise
  RegexpExtractor.new(%w[lloo llo]).extract == /^llo.*$/m or raise
  RegexpExtractor.new(%w[lloo llo]).extract == /^llo.*$/m or raise
  RegexpExtractor.new(%w[lloo llo lloo]).extract == /^llo.*$/m or raise
  RegexpExtractor.new(%w[lloo ll ]).extract == /^ll.*$/m or raise
  RegexpExtractor.new(%w[lloo oll]).extract == /^.*$/m or raise
  RegexpExtractor.new(%w[abcxdef abcvdef]).extract == /^abc.*def$/m or raise

  extract_pattern(*11.times.map { |i| "a#{i}b" }) == /^a.*b$/m or raise

  extract_pattern(*0..10,nil) == {with_nil: 0..10} or raise

  puts :OK
end