# 1) validator:
#    - in memory representation
#    - in readable code (kinda rspec)
#    - code->in_memory feedback is computer readable
# 2) extractor itself

module Validator
  class Spec < Struct.new :element
    def valid?
    end
  end

  module DSL
    def spec &block; @spec = block end
    def validate element
      Spec.new(@spec).valid? element
    end
  end
end

class Module
  def validator; extend Validator::DSL end
end

module Document; validator

  spec do
    children.count == 2 
    name == 'any'    
    # attributes == {...}
  end

  module Html
  end
end

Document.validate '123'