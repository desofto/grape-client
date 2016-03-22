require 'json'

module GrapeClient
  class ResponseParser
    def initialize(response, receiver)
      @response = response
      @receiver = receiver
    end

    def parse
      if @receiver.is_a? Class
        elements = collection
        if elements.nil?
          if parsed.present?
            @receiver.new(parsed)
          else
            @response
          end
        else
          Collection.new(@receiver, elements,
                         @receiver.connection.headers)
        end
      else
        @receiver.attributes = parsed
      end
    end

    def collection
      parsed[@receiver.entity_name.pluralize] if parsed.is_a? Hash
    end

    private

    def parsed
      @parsed ||= JSON.parse @response
    rescue JSON::ParserError
      nil
    end
  end
end
