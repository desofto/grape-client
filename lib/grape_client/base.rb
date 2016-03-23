module GrapeClient
  class Base
    extend Accessors
    mattr_accessor :site, :user, :password, :prefix

    extend RestMethodsCollection
    include RestMethodsMember

    extend BelongsTo

    attr_reader :attributes

    class << self
      def attr_accessor(*names)
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
      self.attributes = attrs
    end

    def attributes=(attrs)
      @attributes = {}
      attributes = self.class.attributes
      attrs.each do |name, value|
        next unless attributes.include?(name.to_sym) || methods.include?(name.to_sym)
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

    def respond_to?(method_name, *args, &block)
      name = method_name.to_s
      name = name[0..-2] if name.last == '='
      self.class.attributes.include?(name.to_sym) || super
    end

    def to_post
      entity_name = self.class.entity_name
      list = self.class.attributes
      filtered_attributes = attributes.select { |key, _value| list.include? key }
      filtered_attributes.transform_keys { |key| "#{entity_name}[#{key}]" }
    end

    private

    def class_from_name(name)
      name.to_s.camelcase.constantize
    end
  end
end
