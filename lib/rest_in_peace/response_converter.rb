module RESTinPeace
  class ResponseConverter
    class UnknownConvertStrategy < RESTinPeace::DefaultError
      def initialize(klass)
        super("Don't know how to convert #{klass}")
      end
    end

    def initialize(response, instance_or_class)
      @response = response

      if instance_or_class.respond_to?(:new)
        @class = instance_or_class
        @existing_instance = new_instance
      else
        @class = instance_or_class.class
        @existing_instance = instance_or_class
      end
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
        raise UnknownConvertStrategy, @response.body.class
      end
    end

    def convert_from_array
      @response.body.map do |entity|
        convert_from_hash(entity, new_instance)
      end
    end

    def convert_from_hash(entity = @response.body, instance = @existing_instance)
      instance.force_attributes_from_hash entity
      instance
    end

    def new_instance
      @class.new
    end
  end
end
