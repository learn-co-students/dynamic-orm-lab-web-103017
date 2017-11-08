require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    row = DB[:conn].execute(sql)
    column = row.collect {|row| row[1]}
    #column.delete('id')
    column
    #binding.pry
  end

  def self.inherited(childclass) #if parent has inherited a child then give attr_accessor
    childclass.column_names.each do |key| #notice childclass
      attr_accessor key.to_sym
    end
  end

  def initialize(attributes={})
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    column_names = self.class.column_names
    column_names.delete('id')
    column_names.join(', ')
  end

  def values_for_insert
    #binding.pry
    data = []
    x = col_names_for_insert.split(', ')
    x.each{|name| data << send("#{name}")}
    data.collect{|each| "'#{each}'"}.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    #binding.pry
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name='#{name}'")
  end

  def self.find_by(hsh) #find the row with a hash of attributes
    #binding.pry
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{hsh.keys.join}='#{hsh.values.join}'")
  end


end
