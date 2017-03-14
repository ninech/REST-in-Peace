module RESTinPeace
  class ResponseConverter
    class UnknownConvertStrategy < RESTinPeace::DefaultError
      def initialize(klass)
        super("Don't know how to convert #{klass}")
      end
    end

    attr_accessor :body, :klass, :existing_instance

    def initialize(response, instance_or_class)
      self.body = response.body

      if instance_or_class.respond_to?(:new)
        self.klass = instance_or_class
        self.existing_instance = new_instance
      else
        self.klass = instance_or_class.class
        self.existing_instance = instance_or_class
      end
    end

    def result
      case body.class.to_s
      when 'Array'
        convert_from_array
      when 'Hash'
        convert_from_hash
      when 'String'
        body
      when 'NilClass'
        nil
      else
        raise UnknownConvertStrategy, body.class
      end
    end

    def convert_from_array
      body.map do |entity|
        convert_from_hash(entity, new_instance)
      end
    end

    def convert_from_hash(entity = body, instance = existing_instance)
      entity_with_indifferent_access = entity.with_indifferent_access

      # We received a validation error and we need to add it to the model.
      if entity_with_indifferent_access[:status] == 422
        instance.errors.add(:base, entity_with_indifferent_access[:message])
      else
        instance.force_attributes_from_hash entity
      end
      instance
    end

    def new_instance
      klass.new
    end
  end
end
