require 'pry'

require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"
    info = DB[:conn].execute(sql)
    columns = []
    info.each {|col| columns << col["name"]}
    columns.compact
  end
  
  def initialize(attrs={})
    attrs.each {|a, value| self.send("#{a}=", value)}
  end
  
  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|name| name == 'id'}.join(', ')
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql1 = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql1)
    sql2 = "SELECT last_insert_rowid() FROM #{table_name_for_insert}"
    @id = DB[:conn].execute(sql2)[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)
  end

  def self.find_by(attribute_hash)
    column = nil
    value = nil
    attribute_hash.each do |k, v|
      column = k.to_s
      value = v
    end
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{column} = ?", value)
  end


end
