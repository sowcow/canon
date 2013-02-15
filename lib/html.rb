# <3 <3 <3 for plain ruby!
# <3 <3 <3 for plain ruby!
# <3 <3 <3 for plain ruby!
require 'nokogiri'

# all_attributes  --  to_html?

module HTML
  def split page
    recurse_children(html(page))
  end
  def texts page
    recurse_children(html(page)).select { |x| x.name == 'text' }
  end  
  def just_attributes node
    node.attributes.map { |k, v| [k, typecasted(v.value)] }
  end
  def attributes node
    other = {name: node.name,
             text: node.text,
             text_size: node.text.size,
             children_count: node.children.count, 
             children_names: node.children.map{ |x| x.name },
             children_classes: node.children.map{ |x| x[:class] },
             children_ids: node.children.map{ |x| x[:id] }}
    just_attributes(node) + other.to_a
  end

  private
  def html page
    Nokogiri::HTML(page).at('html')
  end
  def recurse_children element
    [element] + element.children.map { |x| recurse_children x }.flatten(1)
  end
  def typecasted str
    [str.to_i, str.to_f, str].find { |cast| cast.to_s.sub(?,,?.) == str.sub(?,,?.) }
  end  
end



if __FILE__ == $0
  include HTML

  page = '<ul class=any id=1><li class=a>1</li><li id=b>2</li></ul>'
  html(page).name == 'html' or raise
  split(page).map(&:name) == %w[html body ul li text li text] or raise
  texts(page).map(&:text) == %w[1 2] or raise

  typecasted('0').class == Fixnum or raise
  typecasted('0.').class == String or raise
  typecasted('0.0').class == Float or raise

  just_attributes(html(page).at('ul')) == [%w[class any], ['id', 1]] or raise

  attributes(html(page).at('ul')) == [
    ["class", "any"], ["id", 1], [:name, "ul"], [:text, "12"], [:text_size, 2],
    [:children_count, 2], [:children_names, ["li", "li"]],
    [:children_classes, ['a', nil]], [:children_ids, [nil, 'b']]] or raise

  puts :OK
end