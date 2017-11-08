require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.inherited(childclass)
    childclass.column_names.each do |name|
      attr_accessor name.to_sym
    end
  end

  # self.column_names.each do |name|
  #   attr_accessor name.to_sym # ATTRIBUTE
  # end

  # add the attribute accessors

  def initialize(hash={})
    # assign the attributes here (???)
    hash.each do |k, v| # name = id, name, etc.
      self.send("#{k}=", v)
      # self.k = v # there's no '.k' method
      #binding.pry
    end
  end

  def self.table_name
    # name the table for whatever class tables is inheriting IntRec
    # turn the class object "Student" into "students"
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-SQL
      PRAGMA table_info(#{self.table_name})
    SQL
    columns = DB[:conn].execute(sql)
    columns.map do |column|
      column["name"]
      #binding.pry
    end
  end

  def table_name_for_insert
    #binding.pry
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.reject{|column| column == 'id'}.join(', ')
  end

  def values_for_insert
    column_names = self.class.column_names.reject{|column| column == 'id'}
    # column_names = ["name", "grade"]
    # get 'Sam', '11' from 'name', 'grade'
    column_names.map do |attribute| # "name", "grade"
      arb = self.send(attribute) # add ticks around this whole statement
      # binding.pry
      "'#{arb}'"
    end.join(', ') # we're gonna get an array of name, grade
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} ( #{self.col_names_for_insert} )
      VALUES ( #{self.values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE name = "#{name}"
    SQL
    test = DB[:conn].execute(sql)
    test
  end

  def self.find_by(attribute)
    row = nil
    attribute.each do |k, v|
      sql = <<-SQL
        SELECT *
        FROM #{self.table_name}
        WHERE #{k.to_s} = "#{v}"
      SQL
      # binding.pry
      row = DB[:conn].execute(sql) # gives a row back
    end
    row
  end

end #THIS IS THE END OF MY CODE
