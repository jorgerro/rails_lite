require 'active_support/core_ext'
require 'json'
require 'webrick'
require 'bcrypt'
require_relative '../lib/rails_lite'

  #  MODELS

class User < SQLObject

  def User.find_by_credentials(email, secret)
    @user = User.where( email: email ).first
    # p @user
    return @user if @user && @user.is_password?(secret)
    nil
  end

  def User.generate_session_token
    SecureRandom::urlsafe_base64
  end

  def is_password?(secret)
    bcrypt = BCrypt::Password.new(self.password_digest)
    bcrypt.is_password?(secret)
  end

  def reset_session_token!
    self.session_token = User.generate_session_token
    self.save
    self.session_token
  end

  private
    def ensure_session_token
      self.session_token ||= User.generate_session_token
    end
end


class Post < SQLObject
end


  #  CONTROLLERS

class PagesController < AppController

  def home
    @signed_in = signed_in?
    @current_user = current_user
  end
end


class SessionController < AppController

  def create # sign in a user
    @user = User.find_by_credentials(
      params["user"]["email"],
      params["user"]["password"]
    )

    if @user
      sign_in(@user)
      p "the session token after signing in is: #{ session['token'] }"

      redirect_to "/"
      return
    else
      render :new
    end
  end

  def new
    render :new
  end

  def destroy # sign out a user
    p "in the session#destroy"
    p @req
    p "session:"
    p @session
    p session
    sign_out
    redirect_to "/"
  end

end


class UsersController < AppController

  def index
    @signed_in = signed_in?
    @current_user = current_user
    @users = User.all
  end

  def new
    @signed_in = signed_in?
    @current_user = current_user
    @user = User.new
  end

  def create
    @user = User.new(params["user"])
    @user.password_digest = BCrypt::Password.create(params['password'])
    @user.session_token = User.generate_session_token

    # sign in user:
    session["token"] = @user.session_token

    # save user
    @user.save
    
    redirect_to "/users"
  end

  def show
    @signed_in = signed_in?
    @current_user = current_user
    @user = User.find(params['id'].to_i)
    @posts = Post.where(author_id: @user.id).reverse
  end

  def edit
    @signed_in = signed_in?
    @current_user = current_user
    @user = User.find(params['id'].to_i)

    # redirect if this page does not belong to the current user
    unless @user.id == @current_user.id
      redirect_to "/users"
      return
    end
  end

  def update
    @user = User.find(params['id'].to_i)

    # update the user model's attributes and saves the model
    @user.update_attributes(params['user'])


    # TODO: There is a bug here where it thinks the base url is the user show page,
    # i.e. /users/5 
    redirect_to "/users/#{@user.id}"
  end

end

class PostsController < AppController

  def index
    @signed_in = signed_in?
    @current_user = current_user
    p "in the index"
    p session
    @posts = Post.all
  end

  def new
    @signed_in = signed_in?
    @current_user = current_user
  end

  def create
    @post = Post.new(params["post"])
    @post.save
    redirect_to "/posts"
  end


  def show
    @signed_in = signed_in?
    @current_user = current_user
    @post = Post.find(params['id'].to_i)
  end

end


  #  ROUTER


router = Router.new

router.draw do
  get Regexp.new("^/$"), PagesController, :home

  get Regexp.new("^/session/new$"), SessionController, :new
  post Regexp.new("^/session$"), SessionController, :create
  post Regexp.new("^/session/destroy$"), SessionController, :destroy


  get Regexp.new("^/posts$"), PostsController, :index
  get Regexp.new("^/posts/new$"), PostsController, :new
  post Regexp.new("^/posts$"), PostsController, :create
  get Regexp.new("^/posts/(?<id>\\d+)$"), PostsController, :show

  get Regexp.new("^/users$"), UsersController, :index
  get Regexp.new("^/users/new$"), UsersController, :new
  post Regexp.new("^/users$"), UsersController, :create
  get Regexp.new("^/users/(?<id>\\d+)$"), UsersController, :show
  get Regexp.new("^/users/(?<id>\\d+)/edit$"), UsersController, :edit
  post Regexp.new("^/users/(?<id>\\d+)$"), UsersController, :update
  post Regexp.new("^/users/(?<id>\\d+)/follow$"), UsersController, :follow
end


  #  SERVER



server = WEBrick::HTTPServer.new :Port => ARGV[1]
trap('INT') { server.shutdown }

server.mount_proc '/' do |req, res|
  router.run(req, res)
end

server.start
#
# # run Proc.new do |req, res|
# #   route = router.run(req, res)
# # end


# Rack::Handler::WEBrick.run -> (env) do
#
#   req = Rack::Request.new(env)
#
#   [200, {"Content-type" => "text/html"}, [ "#{ req.inspect }"]]
#
#
# end


# Rack::Handler::WEBrick.run -> (env) do
#   mount_proc '/' do |req, res|
#     router.run(req, res)
#   end
# end