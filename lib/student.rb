require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  # self.column_names.each do |key| #w/oself.inherited() overrides parent, explicit to child
  #   attr_accessor key.to_sym
  # end
end
