require 'rest_in_peace/definition_proxy/resource_method_definitions'
require 'rest_in_peace/definition_proxy/collection_method_definitions'

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

    def use_api(api)
      @target.api = api
    end
  end
end
