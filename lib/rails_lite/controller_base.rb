require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller

  def initialize(req, res, route_params = {})
    @req, @res = req, res
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render

  def render_content(body, content_type)
    unless already_rendered?
      @res.content_type = content_type
      @res.body = body
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
      @res["location"] = url
      session.store_session(@res)
      @already_rendered = true
      return
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
  end
end
