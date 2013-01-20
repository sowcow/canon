class Code
  def initialize code; @code = code end
  def self.[] *a; new *a end
  attr_reader :code

  def each &block
    code.split(/[;\n]/).map(&:strip).each &block
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

  puts 'OK'
end