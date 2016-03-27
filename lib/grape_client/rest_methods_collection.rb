module GrapeClient
  module RestMethodsCollection
    def create(attrs)
      object = new(attrs)
      object.save!
      object
    end

    def all
      get
    end

    def find(params)
      if params.is_a? Hash
        cache.fetch(params) do
          result = get(nil, params)
          result.is_a?(Collection) ? result.first : result
        end
      else
        cache.fetch(params) do
          get(params)
        end
      end
    end

    def where(conditions)
      get(nil, conditions)
    end

    protected

    def get(method = nil, params = {}, &block)
      request :get, method, params, &block
    end

    def put(method = nil, params = {}, &block)
      request :put, method, params, &block
    end

    def post(method = nil, params = {}, &block)
      request :post, method, params, &block
    end

    def delete(method = nil, params = {}, &block)
      request :delete, method, params, &block
    end

    private

    def request(method, url, params = {}, &_block)
      url = [endpoint, url].compact.join('/')
      method = method.compact.join('/') if method.is_a? Array
      response = connection.request method, url, params
      if block_given?
        yield response
      else
        ResponseParser.new(response, self).parse
      end
    end
  end
end
