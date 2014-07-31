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
      base.extend ActiveModel::Naming

      base.send(:alias_method, :save_without_dirty_tracking, :save)
      base.send(:alias_method, :save, :save_with_dirty_tracking)

      base.send :define_attribute_methods, base.rip_attributes[:write]

      base.rip_attributes[:write].each do |attribute|
        base.send(:define_method, "#{attribute}_with_dirty_tracking=") do |value|
          attribute_will_change!(attribute) unless send(attribute) == value
          send("#{attribute}_without_dirty_tracking=", value)
        end

        base.send(:alias_method, "#{attribute}_without_dirty_tracking=", "#{attribute}=")
        base.send(:alias_method, "#{attribute}=", "#{attribute}_with_dirty_tracking=")
      end
    end

    def self.check_for_missing_methods(base)
      raise MissingSaveMethod, :save unless base.instance_methods.include?(:save)
      raise MissingSaveMethod, :create unless base.instance_methods.include?(:create)
    end

    def save_with_dirty_tracking
      save_without_dirty_tracking
      @changed_attributes.clear
    end
  end
end
