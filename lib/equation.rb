# global vars!

module LastEquation
  classes = [Fixnum, Range]

  classes.each do |klass|
    refine klass do
      def == other
        super.tap { |result| $last_eq = "#{self} == #{other}" } 
      end
      def === other
        super.tap { |result| $last_eq = "#{self} === #{other}" } 
      end  
    end
  end
end

class Equation < Struct.new :equation
  using LastEquation

  def eval object, equation=equation
    object.instance_eval equation
  end
  def text object
    eval(object)
    $last_eq
  end
end

def Eq block
  Equation.new block
end



raise unless Eq('a == 2').eval(stub(a: 2)) == true
raise unless Eq('a == 2').eval(stub(a: 3)) == false
raise unless Eq('a == 2').text(stub(a: 2)) == '2 == 2'
raise unless Eq('a == 2').text(stub(a: 3)) == '3 == 2'
raise unless Eq('(1..3) === a').eval(stub(a: 3)) == true
raise unless Eq('(1..3) === a').eval(stub(a: 4)) == false
raise unless Eq('(1..3) === a').text(stub(a: 3)) == '1..3 === 3'
raise unless Eq('(1..3) === a').text(stub(a: 4)) == '1..3 === 4'

puts 'OK'
BEGIN{ require 'ostruct'; def stub param; OpenStruct.new param end }