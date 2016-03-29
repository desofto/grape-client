module GrapeClient
  class Base
    include RestMethodsMember

    attr_reader :attributes

    class << self
      include RestMethodsCollection
      include BelongsTo
      include HasMany

      attr_reader :attributes
      attr_accessor :site, :user, :password, :prefix

      def inherited(child)
        super
        parent = self
        child.instance_eval do
          @attributes = parent.attributes.try(:dup) || []
          return unless GrapeClient.configuration.present?
          @site       = GrapeClient.configuration.site
          @user       = GrapeClient.configuration.user
          @password   = GrapeClient.configuration.password
          @prefix     = GrapeClient.configuration.prefix
        end
      end

      def attr_accessor(*names)
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
        @entity_name ||= name.split('::').last.underscore
      end

      def endpoint
        @endpoint ||= site + prefix + entity_name.pluralize
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
        send(:"#{name}=", value)
      end
    end

    def [](name)
      @attributes[name.to_sym]
    end

    def []=(name, value)
      @attributes[name.to_sym] = value
    end

    def method_missing(method_name, *args)
      attr_name = map_method_name_to_attribute_name(method_name)
      if self.class.attributes.include? attr_name.to_sym
        if method_name.to_s.last == '='.freeze
          self[attr_name] = args.first
        else
          self[attr_name]
        end
      else
        super
      end
    end

    def respond_to?(method_name, *args, &block)
      super ||
        begin
          self.class.attributes.include?(map_method_name_to_attribute_name(method_name).to_sym)
        end
    end

    def to_post
      list = self.class.attributes
      filtered_attributes = attributes.select { |key, _value| list.include? key }
      entity_name = self.class.entity_name
      filtered_attributes.transform_keys { |key| "#{entity_name}[#{key}]" }
    end

    private

    def map_method_name_to_attribute_name(method_name)
      name = method_name.to_s
      name.last == '='.freeze ? name[0..-2] : name
    end

    def class_from_name(name)
      name.to_s.camelcase.constantize
    end
  end
end
