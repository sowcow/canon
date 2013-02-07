require_relative '../lib/easy_record'
require_relative '../lib/selector'

module GroupPages
  include EasyRecord $group_pages_db || 'temp-group-pages.db'

  ######################################### move pages by two sql calls if needed!
  # class Page < DB
  #   key :name
  #   key :other; serialize :other, Hash # overhead?
  #   has_many :elements
  # end

  class Element < DB
    key :selector
    belongs_to :page
    has_many :attributes
  end

  class Attribute < DB
    key :name
    belongs_to :element
    has_many :values    
  end

  class Value < DB
    key :value
    belongs_to :attribute
  end
end


def group split_db, result_db
  $split_db = split_db
  require_relative '../split/all'

  old = Html2DB
  include GroupPages
  renew

  DB.transaction do
    old::Element.includes(:attributes).find_each do |e|
      # $inc ||= -1; $inc += 1
      # break 0 if $inc == 100

      element = Element.create selector: my_selector(e)
      e.attributes.find_each do |a|
        element.attributes.where(name: a.name).first_or_create.values.create value: a.value
      end
    end
  end
  File.rename DB::DATABASE, result_db
end


if __FILE__ == $0
  result = 'my-temp.db'
  # group '../html-in.db', result # it's too big for testing,
    
  # test using sequel???

  # File.exist?(result) or raise
  # File.delete(result)

  puts :OK
end








BEGIN{###########  dirty...?
class MyNode < Struct.new :name, :all_other, :id, :class
  def initialize(*);super
    x = all_other.find { |x| x[0] == 'id' }
    self[:id] = x[1] if x

    x = all_other.find { |x| x[0] == 'class' }
    self[:class] = x[1] if x
  end
end
def MySelector node
  s = Selector[MyNode[node[0],node[1]]]
  def s.parents; [] end
  s
end
def my_selector element
  path = element.path.map { |x| [x.name, x.attributes.map{|x| [x.name,x.value] }] }
  path.map { |x| MySelector(x) }.join ' > '
  # Selector[element].to_s
end
###########  dirty...?  
}

__END__
# class Page < ActiveRecord::Base
#   key :name
#   key :other; serialize :other, Hash 
#   has_many :elements
# end
#
# class Element < ActiveRecord::Base
#   key :name
#   belongs_to :page    
#   has_many :attributes
#   has_ancestry; key :ancestry
# end
#
# class Attribute < ActiveRecord::Base
#   key :name
#   key :value
#   belongs_to :element
# end

# Page(name) -< Element(name, parent_element) -< Attribute(name, value)
# Element(selector) -< Attribute(name) -< Value(value)
# selector ~ self and parents names/classes/ids ?
require 'active_record'
require 'mini_record'

module DB_Actions
  # def models
  #   constants.map { |x| const_get x }.
  #             select { |x| x.is_a?(Class) && x.superclass == ActiveRecord::Base }   
  # end
  def models
    constants.map { |x| const_get x }.
              select { |x| x.is_a?(Class) && x.superclass == self::DB }   
  end
  def clear
    conn = self::DB.connection
    # to catch sqlite_sequence table when exist...
    tables = conn.execute("SELECT * FROM sqlite_master WHERE type='table'").map{|x|x['name']}
    # tables.reject! &:empty? # abstract class?
    tables.each { |t| conn.execute("DELETE FROM `#{t}`") } 
  end
  def migrate
    models.each &:auto_upgrade!
  end
  def renew
    clear; migrate
  end  
end

module GroupBySelector
  extend self

  def self.open file
    Module.new do
      extend self
      include DB_Actions
      define_method(:database){ file }

      this_module = self
      class DB < ActiveRecord::Base
        self.abstract_class = true
        establish_connection adapter: 'sqlite3', database: this_module.database
      end

      yield
    end
  end

  DATABASE = $group_db || 'temp-group.db'
  def self.database; DATABASE end

  # DB is used in DB_Actions
  class DB < ActiveRecord::Base
    self.abstract_class = true
    establish_connection adapter: 'sqlite3', database: DATABASE
  end

  class Element < DB
    key :selector
    has_many :attributes
  end

  class Attribute < DB
    key :name
    belongs_to :element
    has_many :values    
  end

  class Value < DB
    key :value
    belongs_to :attribute
  end

  extend DB_Actions


  # call it $only $once...
  def group given_db, output
    $split_db = given_db
    require './split/all'           # crap

    GroupBySelector.renew

    Html2DB::Element.all.each do |element|
      p selector element
    end

    File.rename GroupBySelector.database, output  
  end

  def selector element
    require './lib/selector'        # crap
    Selector[element].to_s
  end
end



if __FILE__ == $0
  include GroupBySelector

  GroupBySelector.renew
  [Element,Attribute,Value].map(&:count) == [0,0,0] or raise
  # feed_page '<div></div>'
  # [Page,Element,Attribute].map(&:count) == [1,3,0] or raise
  # Element.all.map(&:id) == [1,2,3] or raise

  File.exist? GroupBySelector.database or raise
  File.delete GroupBySelector.database
  puts :OK
end










__END__
# def group given_database, result_db
#   $split_db = given_database
#   require '../split/all'


#   Element.all.each do |element|
#     feed(db, element)
#   end

#   File.rename temp_db, result_db
# end

# def feed db, element
#   selector = selector(element)
#   # find_or_create(
#   element.attributes.each do |attribute|
#     db[:elements]
#   end
# end

# def selector element
#   Selector[element].to_s
# end


__END__
require 'sequel' # don't want to mess with AR connections and global vars
  temp_db = 'temp-group.db'
  File.delete temp_db if File.exist? temp_db
  db = Sequel.sqlite temp_db

  db.create_table :elements do
    primary_key :id
    String :selector
  end
  db.create_table :attributes do
    primary_key :id
    String :name
  end
  db.create_table :values do
    primary_key :id
    String :value
  end
end

def feed db, element
  selector = selector(element)
  # find_or_create(
  element.attributes.each do |attribute|
    db[:elements]
  end
end

def selector element
  Selector[element].to_s
end


__END__
# # class Element < ActiveRecord::Base
# #   key :selector
# # end
# # how to group them? use other tables?
# class Attribute < ActiveRecord::Base
#   has_many :values
# end
# class Value
#   belongs_to :attribute
# end

# class Selector
#   key :name
#   has_many :attribute_names
# end

# class AttributeName
#   key :name  
#   belongs_to :selector
#   has_many :values
# end

# class Value
#   key :value  
#   belongs_to :attribute_name
# end

# key-value pairs
# class Attribute < ActiveRecord::Base
#   belongs_to :selector
# end

