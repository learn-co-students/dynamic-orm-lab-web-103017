require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(option={})
    option.each do | key, value |
      self.send("#{key}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-SQL
    PRAGMA table_info(#{table_name})
    SQL

    column_names = DB[:conn].execute(sql)
    columns = column_names.map do |row|
      row["name"]
    end
    columns
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    columns = self.class.column_names
    columns.delete("id")
    columns.join(", ")
  end

  def values_for_insert
    #This should be refactored to account for the nil value of the id row
    values = self.class.column_names.map do |column|
      "'#{send(column)}'"
    end
    # Line below deltes the nil value from column_names that is the value of the column of id
    values.delete("''")
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
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0]["last_insert_rowid()"]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(hash)

    key = hash.keys[0]
    value = hash[key]

    sql = <<-SQL
      SELECT *
      FROM table_name
      WHERE key = ?
    SQL

    DB[:conn].execute(sql, value)
  end
end
