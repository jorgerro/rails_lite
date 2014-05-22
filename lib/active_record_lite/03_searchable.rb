require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  # params = {name: "Haskell", color: "calico"}
  def where(params)
    ### sqlite3
    # where_line = params.keys.map(&:to_s).map do |key|
    #   "#{key} = ?"
    # end

    where_line = []
    params.keys.each_with_index do |key, idx|
      where_line << "#{key.to_s} = $#{(idx + 1).to_s}"
    end

    search_values = params.values.map(&:to_s)

    # puts "#{where_line} #{search_values}********************************** "

    query_return = DBConnection.execute(<<-SQL, *search_values)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{where_line.join(' AND ')}
    SQL
    query_return.map do |params_hash|
      self.new(params_hash)
    end

  end
end

# class SQLObject
#   # Mixin Searchable here...
#   extend Searchable
# end
