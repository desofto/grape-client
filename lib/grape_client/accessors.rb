module GrapeClient
  module Accessors
    def mattr_accessor(*attr_names)
      attr_names.each do |attr_name|
        define_singleton_method(attr_name) do
          class_variable_get("@@#{attr_name}")
        end
        define_singleton_method("#{attr_name}=") do |value|
          class_variable_set("@@#{attr_name}", value)
        end
      end
    end
  end
end
