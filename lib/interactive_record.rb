require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
    # binding.pry
  end

  def self.column_names
    sql = "PRAGMA table_info ('#{self.table_name}')"

    table_info = DB[:conn].execute(sql)
    columns = table_info.map do |column|
      column["name"]

    end
    columns

  end

  def self.inherited(childclass)

    childclass.column_names.each do |col|
      attr_accessor col.to_sym
  end

  end

  def initialize(options = {})
    options.each do |p,v|
      self.send("#{p}=",v)
    end

  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if do |col|
      col == "id"
    end.join(", ")
  end

  def values_for_insert
    self.class.column_names.map do |col|
      "'#{send(col)}'" unless send(col).nil?
    end.compact.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)

    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    keys = hash.keys.map{|key| key.to_s + " = ?"}.join()

    values = hash.values.join(", ")
    sql = "SELECT * FROM #{self.table_name} WHERE #{keys}"
    DB[:conn].execute(sql, values)
  end

end
