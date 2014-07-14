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
    Hash[each_pair.to_a]
  end

  protected

  def update_from_hash(hash)
    hash.each do |key, value|
      next unless self.class.members.map(&:to_s).include?(key.to_s)
      send("#{key}=", value)
    end
  end

  module ClassMethods
    attr_accessor :api

    def rest_in_peace(&block)
      definition_proxy = RESTinPeace::DefinitionProxy.new(self)
      definition_proxy.instance_eval(&block)
    end
  end
end
