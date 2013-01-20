module LastEquation
  classes = [Fixnum, Range, String, NilClass] # << add classes here

  classes.each do |klass|
    refine klass do
      def == other
        [super, "#{self.inspect} == #{other.inspect}"]
      end
      def === other
        [super, "#{self.inspect} === #{other.inspect}"]
      end  
    end
  end
end


class Equation < Struct.new :equation
  using LastEquation


  def result object, equation=equation
    object.instance_eval(equation) rescue [:error, equation]
  end

  def eval object
    result(object)[0]
  end
  def text object
    result(object)[1]
  end
end

def Eq block
  Equation.new block
end



if __FILE__ == $0
  require 'ostruct'; def stub param; OpenStruct.new param end


  raise unless Eq('a == 2').eval(stub(a: 2)) == true
  raise unless Eq('a == 2').eval(stub(a: 3)) == false
  raise unless Eq('a == 2').text(stub(a: 2)) == '2 == 2'
  raise unless Eq('a == 2').text(stub(a: 3)) == '3 == 2'
  raise unless Eq('(1..3) === a').eval(stub(a: 3)) == true
  raise unless Eq('(1..3) === a').eval(stub(a: 4)) == false
  raise unless Eq('(1..3) === a').text(stub(a: 3)) == '1..3 === 3'
  raise unless Eq('(1..3) === a').text(stub(a: 4)) == '1..3 === 4'
  
  raise unless Eq('(1..3) === a').result(stub(a: 4)) == [false, '1..3 === 4']

  raise unless Eq('a == 2').result(12345) == [:error, 'a == 2']
  raise unless Eq('a == 2').result(12345) == [:error, 'a == 2']

  raise unless Eq('self == "abc"').result('abc') == [true, '"abc" == "abc"']
  raise unless Eq('self == "ab"').result('abc') == [false, '"abc" == "ab"']
    
  raise unless Eq("name == 'any'").result([1,2]) == [:error, "name == 'any'"]
  raise unless Eq("name == 'any'").result(stub(children: [1,2])) == [false, 'nil == "any"'] #openstruct...

  mock = 'mock'
  def mock.children; [1,2] end
  raise unless Eq("name == 'any'").result(mock) == [:error, "name == 'any'"] #openstruct...

  puts 'OK'
end