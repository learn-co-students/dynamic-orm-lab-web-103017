require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name #gets called on CLASS (IR or STUDENT)
    self.to_s.downcase.pluralize #self is the object that this method is called on
    #self by ITSELF returns the name of the class. We convert the class name to a string
    #downcase it, and pluralize
  end

  def self.column_names #gets called on a class
    table_info = DB[:conn].execute("PRAGMA table_info(#{self.table_name})") #pragma returns an array of hashes because we set it in environment
    #we hold that in an array
    table_info.collect {|column| column["name"]}#loop over the array, and collect the items at column["name"]
  end

  def initialize(attributes = {})#this optionally takes a hash
    #@id = nil
    attributes.each{|key, value| self.send("#{key}=", value)} #go over our hash and call that accessors.
    # =>                                    #call the method
  end

  def table_name_for_insert #called on an instance
    self.class.to_s.downcase.pluralize #
  end

  def col_names_for_insert
    #table_info = DB[:conn].execute("PRAGMA table_info(#{self.table_name_for_insert})")
    #table_info.collect {|column| column["name"]}
    self.class.column_names.delete_if{|index| index == "id"}.join(", ")
    #an instance method that is doing the same thing as column_names, without ID
  end

  def values_for_insert
    
    values = self.col_names_for_insert.split(", ").collect {|item| self.send("#{item}")}
    values.collect{|value| "'#{value}'"}.join(', ')
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    #puts sql
     DB[:conn].execute(sql)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = '#{name}'
    SQL
    #binding.pry
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE #{hash.keys[0].to_s} = '#{hash.values[0].to_s}'
    SQL
    #binding.pry
    DB[:conn].execute(sql)
  end

end
