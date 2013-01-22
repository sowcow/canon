require 'my-sugar'

module MyModel
  module ClassMethods
    def [] *a; new *a end  
  end
end

def Model *params
  StateModel params
end

def StateModel params, state={}
  Module.new do
    @params, @state = params, state

    eval %'
      def initialize #{@params*","}
        #{@params.map{|x|"@#{x}"}*"," +'='+ @params*"," if @params.any?}
        #{@state.keys.map{|x|"@#{x}"}*"," +' = '+ @state.values*"," if @state.keys.any?}
      end 
      attr_reader #{@state.keys.map(&:inspect)*","}
      private
      attr_reader #{@params.map(&:inspect)*","}'      


    def self.included target
      target.extend MyModel::ClassMethods
    end
  end
end


if __FILE__ == $0
  class My; include StateModel([:a], b: 2)
    def initialize *a;super
      @c = 3
    end
  end
  
  class My2; include Model(:a, :b)
    def initialize *a;super
      @c = 3
    end
  end

  raise unless My.new(1).instance_eval{ a } == 1
  raise unless My.new(1).b == 2
  raise unless My[1].b == 2
  raise unless My.new(1).instance_eval{ @c } == 3
  raise unless My.new(1).instance_eval{ @params }.nil?
  raise unless My.new(1).instance_eval{ @state }.nil?

  raise unless My2.new(1,2).instance_eval{ a } == 1
  raise unless My2.new(1,2).instance_eval{ @c } == 3

  puts 'OK'
end