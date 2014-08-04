module RESTinPeace
  class ResponseConverter
    def initialize(response, klass)
      @response = response
      @klass = klass
    end

    def result
      case @response.body.class.to_s
      when 'Array'
        convert_from_array
      when 'Hash'
        convert_from_hash
      when 'String'
        @response.body
      else
        raise "Don't know how to convert #{@response.body.class}"
      end
    end

    def convert_from_array
      @klass = @klass.class if existing_object?
      @response.body.map do |entity|
        convert_from_hash(entity)
      end
    end

    def convert_from_hash(entity = @response.body)
      object.tap do |obj|
        obj.force_attributes_from_hash entity
      end
    end

    def object
      existing_object? ? @klass : @klass.new
    end

    def existing_object?
      !@klass.respond_to?(:new)
    end
  end
end
