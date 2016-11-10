require 'active_model'
require 'active_support/core_ext/object/blank'

module RESTinPeace
  module ActiveModelAPI
    class MissingMethod < RESTinPeace::DefaultError
      def initialize(method)
        super "No #{method} method has been defined. "\
              'Maybe you called acts_as_active_model before defining the api endpoints?'
      end
    end

    def self.included(base)
      check_for_missing_methods(base)

      base.send(:include, ActiveModel::Conversion)
      base.extend ActiveModel::Naming
      base.extend ActiveModel::Translation

      base.send(:alias_method, :save_without_dirty_tracking, :save)
      base.send(:alias_method, :save, :save_with_dirty_tracking)
      base.send(:alias_method, :create_without_dirty_tracking, :create)
      base.send(:alias_method, :create, :create_with_dirty_tracking)

      def base.lookup_ancestors
        [self]
      end
    end

    def self.check_for_missing_methods(base)
      raise MissingMethod, :save unless base.instance_methods.include?(:save)
      raise MissingMethod, :create unless base.instance_methods.include?(:create)
    end

    def save_with_dirty_tracking
      save_without_dirty_tracking.tap do
        clear_changes if valid?
      end
      valid?
    end

    def create_with_dirty_tracking
      create_without_dirty_tracking.tap do
        clear_changes if valid?
      end
      valid?
    end

    def valid?
      !errors.any?
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
      new_errors.each do |field, errors|
        errors.each do |error|
          self.errors.add(field.to_sym, error)
        end
      end
    end
  end
end
