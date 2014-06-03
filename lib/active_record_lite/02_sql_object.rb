require_relative 'db_connection'
# require_relative '01_mass_object'
# require_relative '00_attr_accessor_object'
require_relative '03_searchable'
require 'active_support/inflector'
# require "sqlite3"

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
  extend Searchable

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
    # sqlite3
    # cols = DBConnection.execute2("SELECT * FROM #{table_name}")[0].map(&:to_sym)

    # postgres
    cols = DBConnection.get_columns("SELECT * FROM #{table_name}").map(&:to_sym)
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
    WHERE #{table_name}.id = $1
    SQL
    hash = array.first
    self.new(hash)
  end

  def self.find_by_sql(query_string)
    results = []
    array = DBConnection.execute(query_string)
    array.each do |hash|
      results << self.new(hash)
    end
    results
  end

  def self.find_followers_of_user_number(id)
    followers = []
    array = DBConnection.execute(<<-SQL, id)
      SELECT users.*
      FROM users
      WHERE users.id in (
        SELECT
        followings.follower_id
        FROM users JOIN followings ON users.id = followings.user_id
        WHERE followings.user_id = $1
      )
      ORDER BY users.id;
      SQL

    array.each do |hash|
      followers << self.new(hash)
    end
    followers
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

  def update_attributes(params = {})
    cols = self.class.columns

    params.each do |attr_name, value|
      if !cols.include?(attr_name.to_sym)
        raise "unknown attribute #{attr_name}" unless attr_name == "password"
      else
        self.send("#{attr_name}=".to_sym, value)
      end
    end

    self.save
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    ### sqlite 3
    # question_marks = (["?"] * col_names.length).join(", ")

    vars = []
    col_names.length.times do |idx|
      vars << "$#{(idx + 1).to_s}"
    end
    question_marks = vars.join(", ")

    DBConnection.execute(<<-SQL, *(attribute_values))
    INSERT INTO
      #{self.class.table_name} (#{col_names.join(', ')})
    VALUES
      (#{question_marks})
    SQL


    # TODO: May want to reinstate this functionality (so that the model object immediately has an ID)
    # self.id = DBConnection.last_insert_row_id
  end

  def update
    ### sqlite3
    # set_string = col_names[1..-1].map do |col_name|
    #   "#{col_name} = ?"
    # end
    # configured_attributes = (attribute_values[1..-1] + [self.id]).map(&:to_s)


    id_set = ""
    cols = col_names[1..-1]
    set_array = []
    cols.each_with_index do |col, idx|
      set_array << "#{col} = $#{ (idx + 1).to_s }"
      if idx == cols.length - 1
        id_set = "id = $#{ (idx + 2).to_s }"
      end
    end

    configured_attributes = (attribute_values[1..-1] + [self.id])

    # puts "configured attributes: #{configured_attributes} ***************************"

    DBConnection.execute(<<-SQL, *configured_attributes)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_array.join(', ')}
    WHERE
      #{id_set}
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
