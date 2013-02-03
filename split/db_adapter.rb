require 'active_record'
require 'mini_record'
require 'ancestry'

module Html2DB
  DATABASE = 'temp.db'
  def self.database; DATABASE end
  # nice place for this:
  ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: database

  class Element < ActiveRecord::Base
    # key :name
    key :selector
    # def selector; end
    has_many :attributes
    # has_ancestry
  end
  class Attribute < ActiveRecord::Base
    key :name
    belongs_to :element
    has_many :values
  end
  class Value < ActiveRecord::Base
    key :value
    belongs_to :attribute
  end

  def self.models
    constants.map { |x| const_get x }.
              select { |x| x.is_a?(Class) && x.superclass == ActiveRecord::Base }   
  end
  def self.clear
    models.each &:delete_all
  end
  def self.migrate
    models.each &:auto_upgrade!
  end
  def self.renew
    clear; migrate
  end
end

Html2DB.migrate # why so explicit?

if __FILE__ == $0
  include Html2DB
  raise unless Value.create(value: 123).value == 123
  raise unless Attribute.create(name: 'class', values:[Value.create(value: 123)]).name == 'class'
  raise unless Attribute.create(name: 'class', values:[Value.create(value: 123)]).values.first.value == 123
  raise unless Element.create(selector: 'html > body', attributes:[Attribute.create(name: 'class')]).attributes.first.name == 'class'
  raise unless Element.create(selector: 'html > body', attributes:[Attribute.create(name: 'class')]).selector == 'html > body'
  File.delete Html2DB.database
  puts :OK
end