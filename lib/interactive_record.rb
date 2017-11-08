require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"

    DB[:conn].execute(sql).collect do |hsh|
      hsh["name"]
    end

  end

  def initialize(attributes={})
    @id = nil
    attributes.each do |k,v|
      setter = "#{k}="
      if self.respond_to?(setter)
        self.send("#{k}=",v)
      end
    end
  end

  def self.inherited(childclass)
    childclass.column_names.each{|column| attr_accessor column.to_sym}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")

  end

  def question_marks
    self.col_names_for_insert.split(", ").collect do |col|
      "?"
    end.join(", ")

  end

  def values_for_insert
    self.col_names_for_insert.split(", ").collect do |col|
      "'#{self.send(col.to_sym)}'"
    end.join(", ")
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name).flatten
  end

  def self.find_by(attr_hash)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attr_hash.keys[0].to_s} = ?"
    row = DB[:conn].execute(sql, attr_hash.values[0])

  end

  def self.new_by_row(row)
    instance = self.new(row)
    instance.instance_variable_set(:@id, row["id"])
    instance
  end


end
