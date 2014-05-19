
class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name =
                    pattern, http_method, controller_class, action_name
  end

  # checks if pattern matches path and method matches request method

  def matches?(req)
    req.path =~ @pattern && req.request_method.downcase.to_sym == @http_method
  end

  # use pattern to pull out route params (save for later?) -----
  # instantiate controller and call controller action

  def run(req, res)
    match_data = @pattern.match(req.path)
    match_data_hash = Hash[ match_data.names.zip( match_data.captures ) ]
    # route_params = {}
      # match_data_hash.each do |k,v|
      #   route_params[k.to_sym] = v
      # end
      # changes the match data hash keys to symbols, necessary?

    controller_instance = @controller_class.new(req, res, match_data_hash)
    controller_instance.invoke_action(@action_name.to_sym)
  end

end






class Router
  attr_reader :routes

  def initialize
    @routes ||= []
  end

  # simply adds a new route to the list of routes

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)

  def draw(&proc)
    instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request

  def match(req)
    @routes.select do |route|
      req.path =~ route.pattern && req.request_method == route.http_method.to_s.upcase
    end.first
  end

  # either throw 404 or call run on a matched route

  def run(req, res)
    if match(req)
       match(req).run(req, res)
    else
      res.status = 404
    end
  end

end
