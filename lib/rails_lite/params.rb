require 'uri'


# class Params
#   # initialize merges params from query string, post body, and route params
#
#   def initialize(req, route_params = {})
#     @params = {}
#     @params = parse_www_encoded_form(req.query_string)
#     unless parse_www_encoded_form(req.body).empty?
#       @params = parse_www_encoded_form(req.body)
#     end
#     @params = @params.merge(route_params)
#
#   end
#
#   def [](key)
#     @params[key]
#   end
#
#   def permit(*keys)
#     @permitted_keys ||= []
#     @permitted_keys.concat(keys)
#   end
#
#   def require(key)
#     raise AttributeNotFoundError unless @params.keys.include?(key)
#   end
#
#   def permitted?(key)
#     @permitted_keys.include?(key)
#   end
#
#   def to_s
#     JSON.generate(@params)
#   end
#
#   class AttributeNotFoundError < ArgumentError; end;
#
#   # private
#
#   # this should return deeply nested hash
#   # argument format
#   # user[address][street]=main&user[address][zip]=89436
#   # should return
#   # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
#
#   def parse_www_encoded_form(www_encoded_form)
#
#     if www_encoded_form.nil?
#       return {}
#     end
#
#     decoded_uri_array = URI.decode_www_form(www_encoded_form)
#
#     if @params.empty?
#       output_hash = {}
#     else
#       output_hash = @params
#     end
#
#     decoded_uri_array.each do |key, value|
#       nest = output_hash
#       parsed_keys = parse_key(key)
#       parsed_keys.each do |nested_key|
#         if nested_key == parsed_keys[-1]
#           nest[nested_key] = value
#         else
#           nest[nested_key] ||= {}
#           nest = nest[nested_key]
#         end
#       end
#     end
#     output_hash
#   end
#
#   # this should return an array
#   # user[address][street] should return ['user', 'address', 'street']
#
#   def parse_key(key)
#     key.split(/\]\[|\[|\]/)
#   end
#
# end


class Params
  def initialize(req, route_params={})
    @params = {}

    @params.merge!(route_params)
    if req.body
      @params.merge!(parse_www_encoded_form(req.body))
    end
    if req.query_string
      @params.merge!(parse_www_encoded_form(req.query_string))
    end

    @permitted = []
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted.push *keys
  end

  def require(key)
    raise AttributeNotFoundError unless @params.has_key?(key)
    @params[key]
  end

  def permitted?(key)
    @permitted.include?(key)
  end

  def to_s
    @params.to_json.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  def parse_www_encoded_form(www_encoded_form)
    params = {}

    key_values = URI.decode_www_form(www_encoded_form)
    key_values.each do |full_key, value|
      scope = params

      key_seq = parse_key(full_key)
      key_seq.each_with_index do |key, idx|
        if (idx + 1) == key_seq.count
          scope[key] = value
        else
          scope[key] ||= {}
          scope = scope[key]
        end
      end
    end

    params
  end

  def parse_key(key)
    key.split(/\[|\]\[|\]/)
  end
end