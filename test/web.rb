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


class Status < SQLObject
end


  #  CONTROLLERS

class PagesController < AppController

  def home
    # p session
    # p current_user
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

  def new
    @user = User.new
  end

  def create
    @user = User.new(params["user"])
    @user.password_digest = BCrypt::Password.create(params['password'])
    @user.session_token = User.generate_session_token
    @user.save
    redirect_to "users"
  end

  def index
    @users = User.all
  end
end

class StatusesController < AppController

  def index
    p "in the index"
    p session
    @statuses = Status.all
  end

  def new
  end

  def create
    @status = Status.new(params["status"])
    @status.save
    redirect_to "statuses"
  end


  def show
    @status = Status.find(params['id'].to_i)
  end

end


  #  ROUTER


router = Router.new
router.draw do
  get Regexp.new("^/$"), PagesController, :home

  get Regexp.new("^/session/new$"), SessionController, :new
  post Regexp.new("^/session$"), SessionController, :create
  post Regexp.new("^/session/destroy$"), SessionController, :destroy


  get Regexp.new("^/statuses$"), StatusesController, :index
  get Regexp.new("^/statuses/new$"), StatusesController, :new
  post Regexp.new("^/statuses$"), StatusesController, :create
  get Regexp.new("^/statuses/(?<id>\\d+)$"), StatusesController, :show

  get Regexp.new("^/users$"), UsersController, :index
  get Regexp.new("^/users/new$"), UsersController, :new
  post Regexp.new("^/users$"), UsersController, :create
end


  #  SERVER


server = WEBrick::HTTPServer.new :Port => 3000
trap('INT') { server.shutdown }

server.mount_proc '/' do |req, res|
  route = router.run(req, res)
end

server.start

# run Proc.new  mount_proc '/' do |req, res|
#   route = router.run(req, res)
# # end