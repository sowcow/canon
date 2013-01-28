# TODO
# TODO
# TODO
# TODO pending tests
# TODO raise normal errors with normal messages
# TODO more test cases
# TODO def Klass *a,&b; Klass.new *a,&b end   out of scope???
# TODO state - lambda
# TODO state - ruby2 optional params?
# TODO
# TODO
# TODO

require 'my-sugar'

module MyModel
  module ClassMethods
    def [] *a; new *a end  
  end
end

def Model *params,hash
  hash.is_a?(Hash) ? Model__(params, hash) : Model__(params + [hash])
end

def Model__ params, state={}
  Module.new do
    @params, @state = params, state

    # :b! ~ &b
    raise '>1 &block-params(!)' if @params.count { |x| x =~ /!$/ } > 1
    if @block_param = @params.find { |x| x =~ /!$/ }
      @without_ampersand = @block_param[/^(.*)!$/,1].to_s
      @with_ampersand = ?& + @without_ampersand

      @params[@params.index(@block_param)] = @with_ampersand
    end

    # [:a] ~ *a
    raise '>1 *splat-[params]' if @params.count { |x|x.is_a?(Array) } > 1
    if @splat_param = @params.find { |x|x.is_a?(Array) }
      raise 'syntax error using splat param [:any] => *any' unless @splat_param.size == 1 && ! @splat_param[0].is_a?(Array)
      
      @without_asterisk = @splat_param[0].to_s
      @with_asterisk = ?* + @without_asterisk

      @params[@params.index(@splat_param)] = @with_asterisk
    end

    first_lines = "def initialize #{@params*","}"

    @params[@params.index(@with_asterisk)] = @without_asterisk if @splat_param
    @params[@params.index(@with_ampersand)] = @without_ampersand if @block_param

    # if @params.is_a?(Array) && @params.size == 1 && @params[0].is_a?(Array) #&& @params[0].size == 1
    #   @params = @params[0]
    #   first_lines = "def initialize *#{@params*","}"
    # else
    #   first_lines = "def initialize #{@params*","}"
    # end

    eval %'
      #{first_lines}
        #{@params.map{|x|"@#{x}"}*"," +'='+ @params*"," if @params.any?}
        #{@state.keys.map{|x|"@#{x}"}*"," +' = '+ @state.values.map(&:inspect)*"," if @state.keys.any?}
      end 
      attr_accessor #{@state.keys.map(&:inspect)*","}
      private
      attr_reader #{@params.map(&:inspect)*","}'      


    def self.included target
      target.extend MyModel::ClassMethods
    end
  end
end


if __FILE__ == $0
require 'testdo'
test do  
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

  Class.new { is Model(:a, :b, c: 3); self }.new(1,2).instance_eval { a } === 1
  Class.new { is Model(:a, :b, c: 3); self }.new(1,2).instance_eval { b } === 2
  Class.new { is Model(:a, :b, c: 3); self }.new(1,2).instance_eval { @c } === 3

  Class.new { is Model(:a, c: 3); self }.new(1).instance_eval { a } === 1
  Class.new { is Model(:a, c: 3); self }.new(1).instance_eval { b rescue :none } === :none
  Class.new { is Model(:a, c: 3); self }.new(1).instance_eval { @c } === 3

  Class.new { is Model(:a, :b); self }.new(1,2).instance_eval { a } === 1
  Class.new { is Model(:a, :b); self }.new(1,2).instance_eval { b } === 2
  Class.new { is Model(:a, :b); self }.new(1,2).instance_eval { @c } === nil

  Class.new { is Model(c: 3); self }.new.instance_eval { a rescue :none } === :none
  Class.new { is Model(c: 3); self }.new.instance_eval { b rescue :none } === :none
  Class.new { is Model(c: 3); self }.new.instance_eval { @c } === 3

  Class.new { is Model(:a, c: 3); self }.new(1).c === 3
  Class.new { is Model(:a, c: 3); self }.new(1).instance_eval{ @params } === nil
  Class.new { is Model(:a, c: 3); self }.new(1).instance_eval{ @state } === nil
  Class.new { is Model(:a, c: 3); self }[1].c === 3

  Class.new { is Model(:a, c: nil); self }[1].c === nil


  Class.new { is Model([:any]); self }[1,2,3,4,5].instance_eval{ @any } === [1,2,3,4,5]

  Class.new { is Model([:any], c: 6); self }[1,2,3,4,5].instance_eval{ @any } === [1,2,3,4,5]
  Class.new { is Model([:any], c: 6); self }[1,2,3,4,5].c === 6

  Class.new { is Model(:block!); self }.new{ 123 }.instance_eval{ @block }.call === 123


  Class.new { is Model(c: 3); self }.new.instance_eval { self.c = 4;self }.c === 4

  # NOT SO FAST NOT SO FAST NOT SO FAST NOT SO FAST NOT SO FAST
  # TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 
  # Class.new { is Model([:any], c: 1); self }[1,2,3,4,5, c: 6].instance_eval{ @any } == [1,2,3,4,5]
  # Class.new { is Model([:any], c: 1); self }[1,2,3,4,5, c: 6].c == 6
  # TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 

end
end