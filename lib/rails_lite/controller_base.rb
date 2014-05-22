require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require_relative '../active_record_lite/02_sql_object.rb'
require_relative '../active_record_lite/03_searchable.rb'


class ControllerBase
  attr_reader :params, :req, :res

  # grab the request and response to populate the response

  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render

  def render_content(body, content_type)
    unless already_rendered?
      @res.content_type = content_type
      @res.body = body

      session.store_session(@res)
      @already_built_response = true
      return
    end
    raise  "Double Render Error"
  end

  # helper method to alias @already_rendered

  def already_rendered?
    @already_rendered || @already_built_response
  end

  # set the response status code and header

  def redirect_to(url)
    unless already_rendered?
      @res.status = 302
      @res.header["location"] = url

      session.store_session(@res)
      @already_rendered = true
      return nil
    end
    raise "Double Render Error"
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content

  def render(template_name)
    unless already_rendered?
      controller_name = self.class.to_s.tableize[0..-2]
      file_path = "views/#{controller_name}/#{template_name.to_s}.html.erb"
      template = ERB.new(File.read(file_path))

      session.store_session(@res)
      render_content(template.result(binding), "text/html")
      return
    end
    raise "Double Render Error"
  end

  # method exposing a `Session` object

  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)

  def invoke_action(name)
    self.send(name.to_sym)
    render(name) unless already_rendered?
  end

end


### Solution
# class ControllerBase
#   attr_reader :params, :req, :res
#
#   def initialize(req, res, route_params={})
#     @req = req
#     @res = res
#
#     @already_built_response = false
#
#     @params = Params.new(req, route_params)
#   end
#
#   def session
#     @session ||= Session.new(@req)
#   end
#
#   def already_built_response?
#     @already_built_response
#   end
#
#   def redirect_to(url)
#     raise "double render error" if already_built_response?
#     p "redirecting"
#
#
#     @res.status = 302
#     @res.header['location'] = url
#
#     # p "the response to be stored in the session is #{p @res}"
#     # p @res
#
#     session.store_session(@res)
#
#     @already_built_response = true
#     nil
#   end
#
#   def render_content(content, type)
#     raise "double render error" if already_built_response?
#     p "rendering content"
#
#     @res.body = content
#     @res.content_type = type
#     session.store_session(@res)
#
#     @already_built_response = true
#     nil
#   end
#
#   def render(template_name)
#     p "rendering"
#     template_fname =
#       File.join("views", self.class.name.underscore, "#{template_name}.html.erb")
#     render_content(
#       ERB.new(File.read(template_fname)).result(binding),
#       "text/html"
#     )
#   end
#
#   def invoke_action(name)
#     self.send(name)
#     render(name) unless already_built_response?
#
#     nil
#   end
#
#   # routing
# end


class AppController < ControllerBase

  def initialize(req, res, route_params={})
    super
  end

  def current_user
    p "in current user method"
    p "session:"
    p @session
    p session
    # return nil if User.where(session_token: session["token"]).empty?
    @current_user ||= User.where(session_token: session["token"]).first
  end

  def sign_in(user)
    p "in sign_in method"
    user.reset_session_token!
    session["token"] = user.session_token
    p "does #{user.session_token} == #{session["token"]}?"
  end

  def sign_out
    p "In the signout method"
    p current_user
    current_user.reset_session_token!
    session["token"] = nil
  end

  def signed_in?
    !!current_user
  end

  # def require_signed_in!
#     redirect_to new_session_url unless signed_in?
#   end

end