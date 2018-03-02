# Simple Flowdock library
require 'net/http'
require 'uri'
require 'json'

class NoDepFlowdockError < RuntimeError; end

# Flowdock notification
class NoDepFlowdock
  ENDPOINT = 'https://api.flowdock.com/v1/messages/chat/%s'.freeze
  HEADERS = { 'Content-Type' => 'application/json' }.freeze

  def self.chat_message(flow_token, msg, ext_name, *tags)
    obj = {
      'content' => msg,
      'external_user_name' => ext_name,
      'tags' => tags
    }
    post(flow_token, obj)
  end

  def self.post(flow_token, obj)
    http, path = http_path(flow_token)
    request = Net::HTTP::Post.new(path, HEADERS)
    json = obj.to_json
    request.body = json
    return if (resp = http.request(request)).is_a?(Net::HTTPSuccess)
    raise NoDepFlowdockError, "Failed to post chat message: #{json} response: "\
                              "#{resp} response body: #{resp.body}"
  end

  def self.http_path(flow_token)
    uri = URI.parse(format(ENDPOINT, flow_token))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    path = uri.request_uri
    [http, path]
  end

  private_class_method :post, :http_path
end
