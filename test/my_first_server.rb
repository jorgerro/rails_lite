require 'webrick'

server = WEBrick::HTTPServer.new Port: 8080

server.mount_proc '/' do |request, response|
  response.content_type = 'text/text'
  request_path = request.path
  if request.path =~ /jorge/
    response.body = request_path[1..-1] + " is " + "The greatest."
  else
    response.body = request_path[1..-1] + " womp womp"
  end

end

# trap('INT') { server.shutdown }

server.start