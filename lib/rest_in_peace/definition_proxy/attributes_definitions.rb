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
        @target.send(:attr_writer, *attributes)
        @target.rip_attributes[:write].concat(attributes)
      end
    end
  end
end
