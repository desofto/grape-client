module GrapeClient
  module HasMany
    def has_many(property, options = {})
      define_method(property) do
        clazz = class_from_name(options[:class_name] || property.to_s.singularize)
        case @attributes[property]
        when Collection then @attributes[property]
        when nil
          @attributes[property] = clazz.where("#{self.class.entity_name}_id" => id)
        else
          @attributes[property].map! do |element|
            next element unless element.is_a? Hash
            clazz.new(element)
          end
        end
      end

      define_method("#{property}=") do |array|
        @attributes[property] = array
      end
    end
  end
end
