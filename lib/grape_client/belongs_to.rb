module GrapeClient
  module BelongsTo
    def belongs_to(property, options = {})
      attr_accessor "#{property}_id"

      define_method("#{property}_id=") do |id|
        @attributes[property] = nil
        self["#{property}_id".freeze] = id
      end

      define_object_getter(property, options)
      define_object_setter(property, options)
    end

    private

    def define_object_getter(property, options = {})
      define_method(property) do
        clazz = class_from_name(options[:class_name] || property)
        if @attributes[property].is_a? Hash
          @attributes[property] = clazz.new(@attributes[property])
        else
          id = self["#{property}_id".freeze]
          @attributes[property] ||= clazz.find(id) if id.present?
        end
      end
    end

    def define_object_setter(property, _options = {})
      define_method("#{property}=") do |value|
        self["#{property}_id".freeze] = value.try(:id) unless value.is_a? Hash
        @attributes[property] = value
      end
    end
  end
end
