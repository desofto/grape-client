module GrapeClient
  module RestMethodsMember
    def save!
      if id.present?
        put(nil, to_post)
      else
        post(nil, to_post) do |response|
          ResponseParser.new(response, self).parse
        end
      end
      self.class.cache.store(self)
    end

    def save
      save!
    rescue Connection::InvalidEntity
      false
    end

    def reload
      get(nil) do |response|
        ResponseParser.new(response, self).parse
      end
      self.class.cache.store(self)
      self
    end

    def destroy
      self.class.cache.remove(self)
      delete
    end

    protected

    def get(method, params = {}, &block)
      method = [id, method].compact.join('/')
      self.class.send(:get, method, params, &block)
    end

    def put(method, params = {}, &block)
      method = [id, method].compact.join('/')
      self.class.send(:put, method, params, &block)
    end

    def post(method, params = {}, &block)
      method = [id, method].compact.join('/')
      self.class.send(:post, method, params, &block)
    end

    def delete(params = {}, &block)
      self.class.send(:delete, id, params, &block)
    end
  end
end
