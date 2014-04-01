require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {}) #take the 0 default out!
    @params = {}
    puts "#{req.query} ****************************"
    parse_www_encoded_form(req.query)

  end

  def [](key)
  end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  # private

  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }

  def parse_www_encoded_form(www_encoded_form)

    return {} if www_encoded_form.nil?

    # #handle params in the query string
    decoded_uri_array = URI.decode_www_form(www_encoded_form)
    #
    # first_key = decoded_uri_array[0][0].split(/\?/)[1]
    # @params[first_key] = decoded_uri_array[0][1]
    #
    decoded_uri_array.each_with_index do |pair, idx|
      # next if idx == 0
      @params[pair[0]] = pair[1]
    end



    output_hash = {}
    @params.each do |key, value|
      nest = output_hash
      parsed_keys = parse_key(key)
      parsed_keys.each do |nested_key|
        if nested_key == parsed_keys[-1]
          nest[nested_key] = value
        else
          nest[nested_key] ||= {}
          nest = nest[nested_key]
        end
      end
    end
    # @params = output_hash
    @params
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
