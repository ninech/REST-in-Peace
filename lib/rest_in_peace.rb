require 'rest_in_peace/definition_proxy'

module RESTinPeace

  def self.included(base)
    base.send :extend, ClassMethods
  end

  def api
    self.class.api
  end

  def initialize(attributes = {})
    attributes.each do |key, value|
      next unless self.class.has_read_attribute?(key)
      instance_variable_set("@#{key}", value)
    end
  end

  def hash_for_updates
    hash_representation = { id: id }
    self.class.rip_attributes[:write].map do |key|
      value = send(key)
      hash_representation[key] = hash_representation_of_object(value)
    end
    hash_representation
  end

  def update_attributes(attributes)
    attributes.each do |key, value|
      next unless self.class.has_write_attribute?(key)
      send("#{key}=", value)
    end
  end

  protected

  def hash_representation_of_object(object)
    return object.hash_for_updates if object.respond_to?(:hash_for_updates)
    return object.map { |element| hash_representation_of_object(element) } if object.is_a?(Array)
    object
  end

  module ClassMethods
    attr_accessor :api

    def rest_in_peace(&block)
      definition_proxy = RESTinPeace::DefinitionProxy.new(self)
      definition_proxy.instance_eval(&block)
    end

    def rip_registry
      @rip_registry ||= {
        resource: [],
        collection: [],
      }
    end

    def rip_attributes
      @rip_attributes ||= {
        read: [],
        write: [],
      }
    end

    def has_read_attribute?(attribute)
      rip_attributes[:read].map(&:to_s).include?(attribute.to_s)
    end

    def has_write_attribute?(attribute)
      rip_attributes[:write].map(&:to_s).include?(attribute.to_s)
    end
  end
end
