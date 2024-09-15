module RpgAi
  module OpenAiFunctions

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def publish(*args)
        @published_methods ||= []
        @published_methods << args
      end

      def published_function_specs
        @published_methods.map do |method_name, description, properties|
          {
            type: 'function',
            function: {
              name: method_name,
              description: description,
              parameters: {
                type: :object,
                properties: properties.transform_values do |spec|
                  spec.delete(:required)
                  spec
                end,
                required: properties.keys,
                additionalProperties: false,
              },
            },
          }
        end
      end
    end

  end
end