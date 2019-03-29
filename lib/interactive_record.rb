require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true 
    sql = "PRAGMA table_info('#{table_name}')"
    
    table_info = DB[:conn].execute(sql)
    
    column_names = []
    table_info.each do |c|
      column_names << c["name"]
    end
    column_names.compact
  end
  
  def initialize(options={})
    options.each do |prop, v|
      self.send("#{prop}=", v)
    end
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if {|c| c == "id"}.join(", ")
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each do |c_name|
      values <<"'#{send(c_name)}'" unless send(c_name).nil?
    end
    values.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert}(#{col_names_for_insert}) VALUES (#{values_for_insert})"
    
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end
  
  def self.find_by(kv_pair)
    key = kv_pair.keys.join() 
    value = kv_pair.values.first
    sql = "SELECT * FROM #{self.table_name} WHERE ? = ?"
    binding.pry
    DB[:conn].execute(sql, key, value)
  end
  
  
end