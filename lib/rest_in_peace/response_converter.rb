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
      else
        raise "Don't know how to convert #{@response.body.class}"
      end
    end

    def convert_from_array
      @response.body.map do |entity|
        convert_from_hash(entity)
      end
    end

    def convert_from_hash(entity = @response.body)
      klass.new entity
    end

    def klass
      @klass.respond_to?(:new) ? @klass : @klass.class
    end
  end
end
