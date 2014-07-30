require 'rest_in_peace/definition_proxy'

module RESTinPeace

  def self.included(base)
    base.send :extend, ClassMethods
  end

  def api
    self.class.api
  end

  def initialize(attributes = {})
    update_from_hash(attributes)
  end

  def to_h
    hash_representation = {}
    attributes.map do |key|
      value = send(key)
      hash_representation[key] = hash_representation_of_object(value)
    end
    hash_representation
  end

  def update_attributes(attributes)
    update_from_hash(attributes)
  end

  def attributes
    self.class.members
  end

  protected

  def update_from_hash(hash)
    hash.each do |key, value|
      next unless attributes.map(&:to_s).include?(key.to_s)
      send("#{key}=", value)
    end
  end

  def hash_representation_of_object(object)
    return object unless object.respond_to?(:to_h)
    if object.is_a?(Array)
      object.map { |element| hash_representation_of_object(element) }
    else
      object.to_h
    end
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
  end
end
