require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def initialize(attr_hash = {})
      attr_hash.each do |prop, val|
        self.send("#{prop}=", val)
      end #each
    end #initialize

    def self.table_name
      self.to_s.downcase.pluralize 
    end #self.table_name

    def table_name_for_insert
      self.class.table_name 
    end #table_name_for_insert

    def self.column_names
      #DB[:conn].results_as_hash = true

      sql = "pragma table_info('#{table_name}')"
  
      table_info = DB[:conn].execute(sql) 
      #table_info is an array of hashes
  
      column_names = []
      table_info.each do |row|
        #Picks of the value associated with the "name" key for each row hash
        column_names << row[1]
      end
      #Removes any 'nil' values from the array before returning it
      column_names.compact
      #column_names_without_indexes = column_names.compact.delete_if{|name| name.is_a? Integer}
      #binding.pry
    end #self.column_names

    def col_names_for_insert
      col_array = self.class.column_names
      col_array.delete_if{|col| col == "id"}.join(", ")
    end #col_names_for_insert

    def values_for_insert
      values = []
      self.class.column_names.each do |col_name|
        values << "'#{send(col_name)}'" unless send(col_name).nil?
      end #each
      values.join(", ")
    end #values_for_insert

    def save
      sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
      DB[:conn].execute(sql)
      #DB[:conn].execute("SELECT * FROM #{table_name_for_insert} WHERE id = (SELECT MAX(id) FROM #{table_name_for_insert})")[0][0]
      id_info = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")
      @id = id_info[0][0]
      #binding.pry 
    end #save

    def self.find_by_name(a_name)
      sql = <<-SQL
        SELECT * FROM #{self.table_name}
        WHERE name = ?
        LIMIT 1
      SQL
      DB[:conn].execute(sql, a_name)
    end #self.find_by_name

    def self.find_by(attr_hash)
      key = attr_hash.keys[0]
      val = attr_hash[attr_hash.keys[0]]
      sql = <<-SQL
        SELECT * FROM #{self.table_name}
        WHERE #{key} = '#{val}'
      SQL
      #binding.pry 
      DB[:conn].execute(sql)
    end #self.find_by
    
end #class