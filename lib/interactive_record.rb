require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord

  def self.table_name
    self.to_s.downcase + 's'
  end

  def self.column_names
    table_info = DB[:conn].execute("PRAGMA table_info(#{self.table_name})")
    var = table_info.map{|row| row["name"]}.compact
  end
  # binding.pry



  def initialize(hash = {})
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end


  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    var = self.class.column_names
    var.delete("id")
    var.join(", ")
    #var
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert}
      (#{col_names_for_insert})
      VALUES
      (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name_input)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name_input)
  end

  def self.find_by(input_hash)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{input_hash.keys[0]} = \'#{input_hash.values[0]}\'
    SQL
    #binding.pry
    DB[:conn].execute(sql)
    #, self.table_name, input_hash.keys[0].to_s, input_hash.values[0])
  end

end
