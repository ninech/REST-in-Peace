require 'active_support/core_ext/hash/indifferent_access'

require 'rest_in_peace/definition_proxy'

module RESTinPeace

  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, ActiveModel::Dirty
  end

  def api
    self.class.api
  end

  def initialize(attributes = {})
    force_attributes_from_hash(attributes)
  end

  def hash_for_updates
    hash_representation = { id: id }
    changed.each do |key|
      value = send(key)
      hash_representation[key.to_sym] = hash_representation_of_object(value)
    end
    if self.class.rip_namespace
      { id: id, self.class.rip_namespace => hash_representation }
    else
      hash_representation
    end
  end

  def clear_changes
    @changed_attributes.clear if @changed_attributes
  end

  def update_attributes(attributes)
    attributes.each do |key, value|
      next unless respond_to?("#{key}=")
      send("#{key}=", value)
    end
  end

  def to_h
    hash_representation = {}
    self.class.rip_attributes.values.flatten.each do |attr|
      hash_representation[attr] = send(attr)
    end
    hash_representation
  end

  def force_attributes_from_hash(attributes)
    attributes.each do |key, value|
      next unless respond_to?(key)
      if respond_to?("#{key}=")
        send("#{key}=", value)
      else
        instance_variable_set("@#{key}", value)
      end
    end
    clear_changes
  end

  def hash_representation_of_object(object)
    return object.hash_for_updates if object.respond_to?(:hash_for_updates)
    return object.map { |element| hash_representation_of_object(element) } if object.is_a?(Array)
    object
  end

  module ClassMethods
    attr_accessor :api
    attr_accessor :rip_namespace

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
  end
end
