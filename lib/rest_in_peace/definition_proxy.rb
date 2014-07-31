require 'rest_in_peace/definition_proxy/resource_method_definitions'
require 'rest_in_peace/definition_proxy/collection_method_definitions'
require 'rest_in_peace/definition_proxy/attributes_definitions'
require 'rest_in_peace/active_model_api'

module RESTinPeace
  class DefinitionProxy
    def initialize(target)
      @target = target
    end

    def resource(&block)
      method_definitions = RESTinPeace::DefinitionProxy::ResourceMethodDefinitions.new(@target)
      method_definitions.instance_eval(&block)
    end

    def collection(&block)
      method_definitions = RESTinPeace::DefinitionProxy::CollectionMethodDefinitions.new(@target)
      method_definitions.instance_eval(&block)
    end

    def attributes(&block)
      method_definitions = RESTinPeace::DefinitionProxy::AttributesDefinitions.new(@target)
      method_definitions.instance_eval(&block)
    end

    def acts_as_active_model
      @target.send(:include, RESTinPeace::ActiveModelAPI)
    end

    def namespace_attributes_with(namespace)
      @target.rip_namespace = namespace
    end

    def use_api(api)
      @target.api = api
    end
  end
end
