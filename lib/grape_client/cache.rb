module GrapeClient
  class Cache
    def initialize
      @objects = {}
    end

    def clear
      @objects.clear
    end

    def fetch(params)
      id = params.is_a?(Hash) ? params[:id] : params
      object = @objects[id] if id.present?
      unless object.present?
        object = yield
        store(object)
      end
      object
    end

    def store(object)
      id = object.try(:id)
      return unless id.present?
      @objects[id] = object
    end

    def remove(object)
      id = object.try(:id)
      return unless id.present?
      @objects[id] = nil
    end

    @instance = Cache.new
    private_class_method :new

    class << self
      attr_reader :instance
    end
  end
end
