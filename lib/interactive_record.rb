require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{table_name});"
    columns = DB[:conn].execute(sql)
    columns.map{ |column| column["name"] }.compact
  end

  def initialize(attr_hash={})
    attr_hash.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.reject{ |name| name == "id" }.join(", ")
  end

  def values_for_insert
    col_names = self.class.column_names.reject{ |name| name == "id" }
    col_names.map{ |col_name| "'#{self.send(col_name)}'"}.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert});
    SQL
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attr_hash)
    col_name = attr_hash.keys[0]
    sql = "SELECT * FROM #{table_name} WHERE #{col_name} = ?"
    DB[:conn].execute(sql, attr_hash[col_name])
  end
end