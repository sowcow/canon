require 'active_record'
require 'mini_record'
# Hey! just DB not self::DB


module EasyRecord
  def self.included target
    target.module_eval <<-EVAL
      class DB < ActiveRecord::Base
        self.abstract_class = true
        establish_connection adapter: 'sqlite3', database: DATABASE
        
        @parent_module = #{target} # hmm... it works...
        singleton_class.send :attr_reader, :parent_module
      end  
    EVAL
  end

  def database; self::DATABASE end


  module DB_Actions
    def clear
      connection.tables.each { |t| connection.execute("drop table if exists `#{t}`") } 
      connection.execute("delete from sqlite_sequence")
    end
    def migrate
      models.each &:auto_upgrade!
    end
    def renew
      clear; migrate
    end 

    private
    def models
      space = DB.parent_module
      space.constants.map { |x| space.const_get x }.select { |x| x.is_a?(Class) && x.superclass == DB }
    end
    def connection
      DB.connection
    end
    def get_module who
      Object.const_get get_module_name who
    end
    def get_module_name who
      who.to_s.split("::").first
    end  
  end  
  include DB_Actions
end

def EasyRecord file
  Module.new do
    @file = file # is this attribute lost after all?
    def self.included target
      target.const_set :DATABASE, @file
      target.send :include, EasyRecord  
      target.extend target # why order matters? getting OK only when this line is last...
    end
  end
end

if __FILE__ == $0 # usage and tests

  module My
    include EasyRecord $my_database || 'temp-example.db'

    class Attribute < DB
      key :name
      has_many :values
    end

    class Value < DB
      key :value
      belongs_to :attribute
    end
  end


  My.database == 'temp-example.db' or raise
  include My

  clear
  DB.connection.tables == [] or raise

  migrate
  DB.connection.tables == %w[attributes values] or raise
  DB.connection.execute('select * from sqlite_sequence') == [] or raise
  
  [Attribute,Value].map(&:count) == [0,0]  or raise
  Attribute.create name: 'any'
  [Attribute,Value].map(&:count) == [1,0]  or raise
  Attribute.create name: 'any'
  [Attribute,Value].map(&:count) == [2,0]  or raise
  Value.create value: 123
  [Attribute,Value].map(&:count) == [2,1]  or raise

  renew
  DB.connection.tables == %w[attributes values] or raise
  DB.connection.execute('select * from sqlite_sequence') == [] or raise
  [Attribute,Value].map(&:count) == [0,0]  or raise

  a = Attribute.create name: 'any'
  a.values.create value: 1
  a.values.create value: 2
  [Attribute,Value].map(&:count) == [1,2]  or raise
  Value.all.map(&:attribute).all? { |x| x == Attribute.first } or raise

  instance_variable_get(:@file) == nil or raise
  My.instance_variable_get(:@file) == nil or raise
  DB.instance_variable_get(:@file) == nil or raise

  puts :OK
end



__END__
    # clear remaining tables (sqlite_sequence)
    tables = connection.execute("SELECT * FROM sqlite_master WHERE type='table'").map{|x|x['name']}
    tables.each { |t| connection.execute("DELETE FROM `#{t}`") } 

class MyDB
  attr_reader :db
  def initialize *a,&b
    extend @db = open(*a,&b)
  end

  private
  def open file, &block
    Module.new {
      # self.name = 'DynModule'
      # def self.name; 'Abc' end
      # def self.table_name; 'A123' end


      define_singleton_method(:database){ file }

      module_eval <<-EVAL
        class DB < ActiveRecord::Base
          self.abstract_class = true
          establish_connection adapter: 'sqlite3', database: "#{file}"
        end  
      EVAL

      @this_module = self
      def self.model name, &block
        klass = @this_module.class_eval <<-DO
          class #{name} < @this_module::DB
            self.table_name = "#{name.to_s.tableize}" # dont likes module name...
            self
          end
        DO
        klass.class_eval &block
      end

      include DB_Actions
      # instance_eval(&block) if block_given?
      block.arity == 0 ? instance_eval(&block) : block.call(self)
    }
  end

  def method_missing name,*a
    if name =~ /^[A-Z]/ && a == [] && ! block_given?
      @db.const_get name
    else
      super
    end
  end
end


module DB_Actions
  def clear
    # to catch sqlite_sequence table when exist...
    tables = connection.execute("SELECT * FROM sqlite_master WHERE type='table'").map{|x|x['name']}
    tables.each { |t| connection.execute("DELETE FROM `#{t}`") } 
  end
  def migrate
    models.each &:auto_upgrade!
  end
  def renew
    clear; migrate
  end 

  private
  def models
    @db.constants.map { |x| @db.const_get x }.select { |x| x.is_a?(::Class) && x.superclass == @db::DB }
  end
  def connection
    @db::DB.connection
  end
end






if __FILE__ == $0
  db = MyDB.new 'temp-my-2.db' do
    model :Attribute do
      self.abstract_class = true
    end
    model :Element do
      self.abstract_class = true
    end    
  end

  db.instance_eval{@db.constants}.include? :DB or raise

  db.instance_eval{@db::Element}.is_a? Class or raise
  db.Element.is_a? Class or raise
  db.instance_eval{@db::Attribute}.is_a? Class or raise
  db.Attribute.is_a? Class or raise

  schema = proc do
    const_set :ANY, 123

    model :Attribute do
      key :name
      has_many :values
    end
    model :Value do
      key :value
      belongs_to :attribute
    end 
  end

  name_1, name_2 = %w[temp-my-schema-1.db temp-my-schema-2.db]
  db1 = MyDB.new name_1, &schema
  db2 = MyDB.new name_2, &schema
  db1.renew; db2.renew # clean + migrate ##################################### FIXME

  db1.send(:connection).tables == ["attributes", "values"] or raise

  attr1 = db1.Attribute.create name: 'a1'
  attr2 = db2.Attribute.create name: 'aa1'
  db1.Attribute.all.map(&:name) == ['a1']
  db2.Attribute.all.map(&:name) == ['aa1']

  db1.Value.create value: 1, attribute: attr1 # FUCK
  attr1.values.create value: 1 # FUCK

  File.exist? name_1 or raise
  File.delete name_1
  File.exist? name_2 or raise
  File.delete name_2

  puts :OK
end




















__END__
  # db = MyDB.new 'temp-my.db' do |db_module|
  #   db_module.const_set('Element', Class.new(db_module::DB){
  #     self.abstract_class = true
  #   })
  # end
    # const_set('Element', Class.new(self::DB){
    #   self.abstract_class = true
    # })   
# module ModelDSL
#   def model name, &block
#     @db.class_eval <<-DO
#       class #{name} < @db.DB
#       end
#     DO
#     # const_set name, Class.new(self::DB, &block)
#     # const_get(name).superclass.inherited const_get(name) # dirty!
#     # name = 'DynamicModule'
#     # klass = class_eval <<-EVAL
#     #   class #{name} < self::DB
#     #     self
#     #   end
#     # EVAL
#     # p name
#     # p const_get(name).name
#     # p 123
#     # p klass.name
#     # klass.instance_eval do
#     #   self.abstract_class = true
#     #   establish_connection adapter: 'sqlite3', database: @db.database #{}"#{database}"
#     # end
#     # self.abstract_class = true
#     # establish_connection adapter: 'sqlite3', database: "#{database}"
#   end
# end


# def DB_Base database, where
#   where.class_eval <<-EVAL
#     class DB < ActiveRecord::Base
#       self.abstract_class = true
#       establish_connection adapter: 'sqlite3', database: "#{database}"
#     end  
#   EVAL
 
  
#   # Module.new do

#   #     class DB < ActiveRecord::Base
#   #       self.abstract_class = true
#   #       establish_connection adapter: 'sqlite3', database: "#{database}"
#   #     end

#     # const_set('DB', Class.new(ActiveRecord::Base){
#     #   self.abstract_class = true
#     #   establish_connection adapter: 'sqlite3', database: database
#     # })
#   # end
# end

# module DB_Base
#   class DB < ActiveRecord::Base
#     self.abstract_class = true
#     establish_connection adapter: 'sqlite3', database: this_module.database
#   end  
# end
def self.open file
  Module.new do
    # extend self
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