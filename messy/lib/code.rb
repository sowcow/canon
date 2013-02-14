class Code
  def initialize code; @code = code end
  def self.[] *a; new *a end
  attr_reader :code

  def each &block
    code.split(/[;\n]/).map(&:strip).reject(&:empty?).each &block
  end
  include Enumerable
end


if __FILE__ == $0
  example = <<-END
    one == 1; two == 2
    three == 3; four == 4
    five == 5
  END
  raise unless Code[example].count == 5
  raise unless Code[example].all? { |x| x.strip == x }

  example = <<-END
  END
  raise unless Code[example].count == 0

  example = <<-END
    one == 1
  END
  raise unless Code[example].count == 1

  example = <<-END
    one == 1;
  END
  raise unless Code[example].count == 1  

  example = <<-END
    one == 1
    two == 2
  END
  raise unless Code[example].count == 2

  example = '
    one == 1
    two == 2'
  raise unless Code[example].count == 2  

  example = 'one == 1
             two == 2'
  raise unless Code[example].count == 2   

  puts 'OK'
end