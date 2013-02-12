module StructBuilder
  def on_top_of other, additional
    (obj = new).members.each_with_object(obj) do |key,obj|
      if other.members.include? key
        obj[key] = other[key]
      elsif additional.keys.include? key
        obj[key] = additional[key]
      else
        raise "probem? :D #{key}"
      end
    end
  end
end

if __FILE__ == $0

  class Point < Struct.new :x, :y
  end

  class MyPoint < Struct.new :x, :y, :name
  end

  class OtherPoint < Struct.new :name, :y, :x
    extend StructBuilder
  end

  OtherPoint.on_top_of(Point[1,2], name: 'any').to_h == {:name=>"any", :y=>2, :x=>1} or raise

  class LessPoint < Struct.new :x
    extend StructBuilder
  end

  LessPoint.on_top_of(Point[1,2], name: 'any').to_h == {:x=>1} or raise

  puts :OK
end