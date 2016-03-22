module GrapeClient
  class Base
    extend Accessors
    mattr_accessor :site, :user, :password, :prefix

    extend RestMethodsCollection
    include RestMethodsMember

    attr_reader :attributes

    class << self
      def field_accessor(*names)
        attributes = self.attributes
        names.each do |name|
          attributes << name.to_sym
        end
      end

      def connection
        @connection ||= Connection.new(user, password)
      end

      def cache
        Cache.instance
      end

      def entity_name
        name.split('::').last.underscore
      end

      def endpoint
        site + prefix + entity_name.pluralize
      end

      def attributes
        class_variable_set('@@attributes', []) unless class_variable_defined?('@@attributes')
        class_variable_get('@@attributes')
      end
    end

    def initialize(attrs = {})
      @attributes = {}
      self.attributes = attrs
    end

    def attributes=(attrs)
      attributes = self.class.attributes
      attrs.each do |name, value|
        next unless attributes.include? name.to_sym
        send("#{name}=", value)
      end
    end

    def [](name)
      name = name.to_sym
      raise NameError, name unless self.class.attributes.include? name
      @attributes[name]
    end

    def []=(name, value)
      name = name.to_sym
      raise NameError, name unless self.class.attributes.include? name
      @attributes[name] = value
    end

    def method_missing(m, *args)
      m = m.to_s
      if m.last == '='
        name = m[0..-2]
        self[name] = args.first
      else
        self[m]
      end
    end

    def to_post
      entity_name = self.class.entity_name
      attributes.transform_keys { |key| "#{entity_name}[#{key}]" }
    end
  end
end
