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
    self.col_names_for_insert
    binding.pry  
  end
  # binding.binding.pry


end #THIS IS THE END OF MY CODE
