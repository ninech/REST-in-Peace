require 'rest_in_peace/definition_proxy'

module RESTinPeace
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def define_api_methods(&block)
      definition_proxy = RESTinPeace::DefinitionProxy.new(self)
      definition_proxy.instance_eval(&block)
    end
  end
end
