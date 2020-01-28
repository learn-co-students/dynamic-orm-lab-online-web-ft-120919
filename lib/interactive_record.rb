require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord


  def initialize(attributes= {})
    attributes.each do |attribute, value|
      if attribute !=:id
        self.send("#{attribute}=", value)
      end
    end
  end

  def self.column_names
    sql = "SELECT * FROM pragma_table_info(?)"
    column_info = DB[:conn].execute(sql, self.table_name)
    column_info.map {|c| c["name"]}
  end

  def self.table_name
    table = self.to_s.downcase.pluralize
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = '#{name}'")
  end

  def self.find_by(attribute)
    column = attribute.keys.first
    value = attribute[column]
    format_value = value.class == String ? "'#{value}'" : value
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{column.to_s} = #{format_value}
    SQL
    row = DB[:conn].execute(sql)
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|c| c == "id"}.join(", ")
  end

  def values_for_insert
    self.col_names_for_insert.split(", ").map {|c| "'#{self.send(c)}'"}.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
end