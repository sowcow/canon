require 'my-sugar'

module MyModel
  module ClassMethods
    def [] *a; new *a end  
  end
end

def Model *params,hash
  unless hash.is_a? Hash
    params = params + [hash]
    hash = {}
  end
  Model__ params, hash
end

def Model__ params, state={}
  Module.new do
    @params, @state = params, state

    eval %'
      def initialize #{@params*","}
        #{@params.map{|x|"@#{x}"}*"," +'='+ @params*"," if @params.any?}
        #{@state.keys.map{|x|"@#{x}"}*"," +' = '+ @state.values.map(&:inspect)*"," if @state.keys.any?}
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
  # class My; include StateModel([:a], b: 2)
  #   def initialize *a;super
  #     @c = 3
  #   end
  # end
  
  # class My2; include Model(:a, :b)
  #   def initialize *a;super
  #     @c = 3
  #   end
  # end

  # raise unless My.new(1).instance_eval{ a } == 1
  # raise unless My.new(1).b == 2
  # raise unless My.new(1).instance_eval{ @c } == 3
  # raise unless My.new(1).instance_eval{ @params }.nil?
  # raise unless My.new(1).instance_eval{ @state }.nil?
  # raise unless My[1].b == 2

  # raise unless My2.new(1,2).instance_eval{ a } == 1
  # raise unless My2.new(1,2).instance_eval{ @c } == 3

  raise unless Class.new { is Model(:a, :b, c: 3); self }.new(1,2).instance_eval { a } == 1
  raise unless Class.new { is Model(:a, :b, c: 3); self }.new(1,2).instance_eval { b } == 2
  raise unless Class.new { is Model(:a, :b, c: 3); self }.new(1,2).instance_eval { @c } == 3

  raise unless Class.new { is Model(:a, c: 3); self }.new(1).instance_eval { a } == 1
  raise unless Class.new { is Model(:a, c: 3); self }.new(1).instance_eval { b rescue :none } == :none
  raise unless Class.new { is Model(:a, c: 3); self }.new(1).instance_eval { @c } == 3

  raise unless Class.new { is Model(:a, :b); self }.new(1,2).instance_eval { a } == 1
  raise unless Class.new { is Model(:a, :b); self }.new(1,2).instance_eval { b } == 2
  raise unless Class.new { is Model(:a, :b); self }.new(1,2).instance_eval { @c } == nil

  raise unless Class.new { is Model(c: 3); self }.new.instance_eval { a rescue :none } == :none
  raise unless Class.new { is Model(c: 3); self }.new.instance_eval { b rescue :none } == :none
  raise unless Class.new { is Model(c: 3); self }.new.instance_eval { @c } == 3

  raise unless Class.new { is Model(:a, c: 3); self }.new(1).c == 3
  raise unless Class.new { is Model(:a, c: 3); self }.new(1).instance_eval{ @params }.nil?
  raise unless Class.new { is Model(:a, c: 3); self }.new(1).instance_eval{ @state }.nil?
  raise unless Class.new { is Model(:a, c: 3); self }[1].c == 3

  raise unless Class.new { is Model(:a, c: nil); self }[1].c == nil

  puts 'OK'
end