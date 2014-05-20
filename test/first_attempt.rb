require 'active_support/core_ext'
require 'json'
require 'webrick'
require_relative '../lib/rails_lite'

# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html


server = WEBrick::HTTPServer.new :Port => 8080
trap('INT') { server.shutdown }

class StatusesController < ControllerBase

  def index
    @statuses = Status.all
    p " the statuses::::: #{p Status.all}"
  end

  def new
  end

  def create
    puts params
    @status = Status.new(params["status"])
    p @status
    @status.save
    redirect_to "statuses"
  end


  def show
    render_content("status ##{params['id']}", "text/text")
  end
end

class Status < SQLObject

end




class UsersController < ControllerBase
  def index
    @users = ["Jorge", "Daniel", "Sam"]
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/statuses$"), StatusesController, :index
  get Regexp.new("^/statuses/new$"), StatusesController, :new
  post Regexp.new("^/statuses$"), StatusesController, :create
  get Regexp.new("^/statuses/(?<id>\\d+)$"), StatusesController, :show

  # uncomment this when you get to route params
  get Regexp.new("^/users$"), UsersController, :index
end

server.mount_proc '/' do |req, res|
  route = router.run(req, res)
end

server.start