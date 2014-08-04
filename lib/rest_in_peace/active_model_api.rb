require 'active_model'

module RESTinPeace
  module ActiveModelAPI
    class MissingSaveMethod < RESTinPeace::DefaultError
      def initialize(method)
        super "No #{method} method has been defined. "\
              'Maybe you called acts_as_active_model before defining the api endpoints?'
      end
    end

    def self.included(base)
      check_for_missing_methods(base)

      base.send(:include, ActiveModel::Dirty)
      base.send(:include, ActiveModel::Conversion)
      base.extend ActiveModel::Naming

      base.send(:alias_method, :save_without_dirty_tracking, :save)
      base.send(:alias_method, :save, :save_with_dirty_tracking)
      base.send(:alias_method, :save_without_attribute_update, :save)
      base.send(:alias_method, :save, :save_with_attribute_update)

      base.send :define_attribute_methods, base.rip_attributes[:write]

      base.rip_attributes[:write].each do |attribute|
        base.send(:define_method, "#{attribute}_with_dirty_tracking=") do |value|
          attribute_will_change!(attribute) unless send(attribute) == value
          send("#{attribute}_without_dirty_tracking=", value)
        end

        base.send(:alias_method, "#{attribute}_without_dirty_tracking=", "#{attribute}=")
        base.send(:alias_method, "#{attribute}=", "#{attribute}_with_dirty_tracking=")
      end

      def base.human_attribute_name(attr, options = {})
        attr.to_s
      end

      def base.lookup_ancestors
        [self]
      end
    end

    def self.check_for_missing_methods(base)
      raise MissingSaveMethod, :save unless base.instance_methods.include?(:save)
      raise MissingSaveMethod, :create unless base.instance_methods.include?(:create)
    end

    def save_with_dirty_tracking
      save_without_dirty_tracking.tap do
        @changed_attributes.clear if @changed_attributes
      end
    end

    def save_with_attribute_update
      result = save_without_attribute_update
      if result.is_a?(self.class)
        force_attributes_from_hash(result.to_h)
        self
      else
        result
      end
    end

    def persisted?
      !!id
    end

    def read_attribute_for_validation(attr)
      send(attr)
    end

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    def errors=(new_errors)
      new_errors.each do |key, value|
        errors.set(key, value)
      end
    end
  end
end
