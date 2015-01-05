module RESTinPeace
  class DefinitionProxy
    class AttributesDefinitions
      def initialize(target)
        @target = target
      end

      def read(*attributes)
        @target.send(:attr_reader, *attributes)
        @target.rip_attributes[:read].concat(attributes)
      end

      def write(*attributes)
        read(*attributes)
        @target.send :attr_writer, *attributes
        @target.send :define_attribute_methods, *attributes
        @target.rip_attributes[:write].concat(attributes)

        attributes.each do |attribute|
          define_dirty_tracking attribute
        end
      end

      private

      def define_dirty_tracking(attribute)
        @target.send(:define_method, "#{attribute}_with_dirty_tracking=") do |value|
          attribute_will_change!(attribute) unless send(attribute) == value
          send("#{attribute}_without_dirty_tracking=", value)
        end

        @target.send(:alias_method, "#{attribute}_without_dirty_tracking=", "#{attribute}=")
        @target.send(:alias_method, "#{attribute}=", "#{attribute}_with_dirty_tracking=")
      end
    end
  end
end
