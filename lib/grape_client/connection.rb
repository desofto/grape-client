require 'net/http'

module GrapeClient
  class Connection
    class UndefinedMethod < StandardError; end
    class Unauthorized < StandardError; end
    class InvalidEntity < StandardError; end
    class UnknownError < StandardError; end

    attr_reader :headers

    def initialize(user, password)
      @user = user
      @password = password
    end

    def request(method, url, params = {})
      uri = prepare_uri(method, url, params)
      req = prepare_request(method, uri, params)

      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end

      @headers = res.to_hash
      validate_response res
    end

    private

    def prepare_uri(method, url, params = {})
      uri = URI(url)
      if params.any? && [:get, :delete].include?(method.to_sym)
        uri.query = URI.encode_www_form(params)
      end

      uri
    end

    def prepare_request(method, uri, params = {})
      req = connector(method).new(uri)
      req.basic_auth @user, @password
      if params.any? && [:put, :post].include?(method.to_sym)
        req.set_form_data(params)
      end

      req
    end

    def validate_response(res)
      case res
      when Net::HTTPUnauthorized        then raise Unauthorized
      when Net::HTTPSuccess             then res.body
      when Net::HTTPUnprocessableEntity then raise InvalidEntity
      else raise UnknownError, res.body
      end
    end

    def connector(method)
      case method.to_sym
      when :get     then Net::HTTP::Get
      when :put     then Net::HTTP::Put
      when :post    then Net::HTTP::Post
      when :delete  then Net::HTTP::Delete
      else raise UndefinedMethod
      end
    end
  end
end
