# global vars!

module LastEquation
  classes = [Fixnum, Range]

  classes.each do |klass|
    refine klass do
      def == other
        super.tap { |result| $last_eq = "#{self.inspect} == #{other.inspect}" } 
      end
      def === other
        super.tap { |result| $last_eq = "#{self.inspect} === #{other.inspect}" } 
      end  
    end
  end
end

class Equation < Struct.new :equation
  using LastEquation

  def eval object, equation=equation
    object.instance_eval equation rescue :error
  end
  def text object
    eval(object)
    $last_eq
  end
  def result object
    [eval(object), $last_eq].tap { |x| x[1] = equation if x[0] == :error }
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

  puts 'OK'
end