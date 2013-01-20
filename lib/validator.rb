require_relative 'code'
require_relative 'equation'


module Validator
  module DSL
    def spec block; @specs = Code[block].map{|x|Eq(x)} end
    def error? element
      if found = @specs.find { |test| failed test.eval(element) }
        found.result(element)
      else false end
    end
    def failed value
      case value
      when :error then true
      else not value end
    end
  end
end

class Module
  def validator; extend Validator::DSL end
end



if __FILE__ == $0
  require 'ostruct'; def stub param; OpenStruct.new param end

  module Document; validator
    spec "children.count == 2"

    module Html; validator
      spec "children.count == 2; name == 'any'"

    end
  end


  raise unless Document.error?(stub(children: [1,2])) == false
  raise unless Document.error?(stub(children: [1,2,3])) == [false, '3 == 2']
  raise unless Document.error?(stub(children: [1])) == [false, '1 == 2']

  raise unless Document::Html.error?(stub(children: [1,2], name: 'any')) == false

  mock = 'mock'
  def mock.children; [1,2] end
  raise unless Document::Html.error?(mock) == [:error, "name == 'any'"]


  puts 'OK'
end