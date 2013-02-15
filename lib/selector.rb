require_relative 'model'


class Selector; is Model(:node)

  def to_s; path * ' > ' end

  # protected
  def to_a; path end

  private
  def path; @path ||= parents + [this] end
  def parents
    node.respond_to?(:parent) && node.parent ? Selector[node.parent].to_a : []
  end
  def this
    [[name, id].compact * '#', klass].compact * '.'
  end

  #
  #  redefine them and return nil to filter crappy classes or ids with numeration like class_1059/my-id_512_foo-bar-baz
  #
  def name; node.name end
  def klass; node[:class] end
  def id; node[:id] end  
end


if __FILE__ == $0  
  require 'nokogiri'; def node! html; Nokogiri.HTML(html).at('html > body').children[0] end
  node = node! '<hey id=cool class=normal value=123></hey>'

  Selector[node].to_s == 'document > html > body > hey#cool.normal' or raise

  class Selector
    def klass; nil end
    def id; nil end      
  end
  Selector[node].to_s == 'document > html > body > hey' or raise

  puts :OK
end