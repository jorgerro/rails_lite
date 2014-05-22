# require 'sqlite3'
require 'pg'

# sqlite3 database connection

# # https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
# ROOT_FOLDER = File.join(File.dirname(__FILE__), "../..")
# RAILS_LITE_SQL_FILE = File.join(ROOT_FOLDER, "test.sql")
# RAILS_LITE_DB_FILE = File.join(ROOT_FOLDER, "test.db")
#
# class DBConnection
#   def self.open(db_file_name)
#     @db = SQLite3::Database.new(db_file_name)
#     @db.results_as_hash = true
#     @db.type_translation = true
#
#     @db
#   end
#
#   def self.reset
#     commands = [
#       "rm #{RAILS_LITE_DB_FILE}",
#       "cat #{RAILS_LITE_SQL_FILE} | sqlite3 #{RAILS_LITE_DB_FILE}"
#     ]
#
#     commands.each { |command| `#{command}` }
#     DBConnection.open(RAILS_LITE_DB_FILE)
#   end
#
#   def self.instance
#     # self.reset if @db.nil?
#     # @db = SQLite3::Database.new(RAILS_LITE_DB_FILE)
#     DBConnection.open(RAILS_LITE_DB_FILE)
#
#     @db
#   end
#
#   def self.execute(*args)
#     puts args[0]
#
#     self.instance.execute(*args)
#   end
#
#   def self.execute2(*args)
#     puts args[0]
#
#     self.instance.execute2(*args)
#   end
#
#   def self.last_insert_row_id
#     self.instance.last_insert_row_id
#   end
#
#   private
#   def initialize(db_file_name)
#   end
# end



# Postgres database connection


# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
# ROOT_FOLDER = File.join(File.dirname(__FILE__), "../..")
# RAILS_LITE_SQL_FILE = File.join(ROOT_FOLDER, "test.sql")
# RAILS_LITE_DB_FILE = File.join(ROOT_FOLDER, "test.db")

class DBConnection
  def self.open#(db_file_name)
    @conn ||= PGconn.open(:dbname => 'testone')

    # @db.type_translation = true

    @conn
  end

  def self.instance
    DBConnection.open#(RAILS_LITE_DB_FILE)

    @conn
  end

  def self.execute(*args)
    puts args[0]

    results = []
    p args
    p self.instance.exec("SELECT * FROM statuses WHERE id = $1", ["1"])[0]
    res = self.instance.exec(args[0], args[1..-1])
    res.each do |result|
      results << result
    end
    p "the results:"
    p results
    results
  end

  def self.get_columns(*args)
    puts args[0]

    self.instance.exec(*args).fields
  end

  def self.last_insert_row_id
    self.instance.last_insert_row_id
  end

  private
  def initialize(db_file_name)
  end
end