require_relative 'db_connection'
# require_relative '01_mass_object'
# require_relative '00_attr_accessor_object'
require 'active_support/inflector'
require "sqlite3"

# class MassObject < AttrAccessorObject
#
#   def self.parse_all(results)
#
#     new_objects = []
#
#     results.each do |hash|
#       new_objects << self.new(hash)
#     end
#     new_objects
#   end
#
# end

class SQLObject #< MassObject


  def self.parse_all(results)

    new_objects = []

    results.each do |hash|
      new_objects << self.new(hash)
    end
    new_objects
  end

  def self.my_attr_accessor(*names)

    names.each do |name|
      define_method("#{name}") do
        self.attributes[name.to_sym]
      end
    end

    names.each do |name|
      define_method("#{name}=") do |new_value|
        self.attributes[name.to_sym] = new_value
      end
    end

  end


  def self.columns
    # db = SQLite3::Database.new "#{table_name}.db"
    # db.results_as_hash = true
    cols = DBConnection.execute2("SELECT * FROM #{table_name}")[0].map(&:to_sym)
    cols.each do |col|
      my_attr_accessor(col)
    end
    cols
  end

  def self.table_name=(table_name = nil)
    @table_name = table_name
  end

  def self.table_name
    if @table_name == nil
      @table_name = "#{self}".tableize
    else
      @table_name
    end
  end

  def self.all
    all = []
    array = DBConnection.execute("SELECT * FROM #{table_name}")
    array.each do |hash|
      all << self.new(hash)
    end
    all
  end

  def self.find(id)
    array = DBConnection.execute(<<-SQL, id)
    SELECT *
    FROM #{table_name}
    WHERE #{table_name}.id = ?
    SQL
    hash = array.first
    self.new(hash)
  end


  def initialize(params = {})
    cols = self.class.columns

    params.each do |attr_name, value|
      if !cols.include?(attr_name.to_sym)
        raise "unknown attribute #{attr_name}" unless attr_name == "password"
      else
        self.send("#{attr_name}=".to_sym, value)
      end
    end

  end

  def attributes
    @attributes ||= {}
  end

  def insert
    question_marks = (["?"] * col_names.length).join(", ")
    DBConnection.execute(<<-SQL, *(attribute_values))
    INSERT INTO
      #{self.class.table_name} (#{col_names.join(', ')})
    VALUES
      (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    question_marks = (["?"] * col_names.length).join(", ")
    set_string = col_names[1..-1].map do |col_name|
      "#{col_name} = ?"
    end

    configured_attributes = (attribute_values[1..-1] + [self.id]).map(&:to_s)
    puts "#{configured_attributes} ***************************"

    DBConnection.execute(<<-SQL, *configured_attributes)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_string.join(', ')}
    WHERE
      id = ?
    SQL

  end

  def save
    if self.id
      self.update
    else
      self.insert
    end
  end

  def attribute_values
    @attributes.values
  end

  def col_names
    @attributes.keys.map(&:to_s)
  end

end
