require 'json'
require 'webrick'

class Session

  # find the cookie for this app
  # deserialize the cookie into a hash

  def initialize(req)

    cookie_dough = req.cookies.select do |cookie|
      cookie.name == '_rails_lite_app'
    end.first

    if cookie_dough
      @cookie = JSON.parse(cookie_dough.value)
    else
      @cookie ||= {}
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
    new_cookie = WEBrick::Cookie.new('_rails_lite_app', JSON.generate(@cookie))
    res.cookies << new_cookie
  end
end
