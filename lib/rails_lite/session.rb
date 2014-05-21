require 'json'
require 'webrick'

class Session

  # find the cookie for this app
  # deserialize the cookie into a hash

  def initialize(req)
    p "initializing session"
    cookie_dough = req.cookies.select do |cookie|
      cookie.name == '_rails_lite_app' #&& JSON.parse(cookie.value)['token'] != nil
    end.first

    if cookie_dough
      @cookie = JSON.parse(cookie_dough.value)
    else
      @cookie = {}
    end
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies

  def store_session(res)
    p "storing session"
    p "This is the cookie that is being serialized in store session: #{@cookie}"
    new_cookie = WEBrick::Cookie.new('_rails_lite_app', JSON.generate(@cookie))
    # new_cookie.expires = "2014-06-01"
    res.cookies << new_cookie
    p "these are the response cookies being sent down"
    p res.cookies
  end
end

# class Session
#   def initialize(req)
#     cookie = req.cookies.find { |c| c.name == "_rails_lite_app" }
#
#     @data = cookie.nil? ? {} : JSON.parse(cookie.value)
#   end
#
#   def [](key)
#     @data[key]
#   end
#
#   def []=(key, val)
#     @data[key] = val
#   end
#
#   def store_session(res)
#     res.cookies << WEBrick::Cookie.new(
#       "_rails_lite_app",
#       @data.to_json
#     )
#
#     p res.cookies
#
#   end
# end