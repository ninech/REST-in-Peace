require 'rest_in_peace/template_sanitizer'
require 'rest_in_peace/api_call'

module RESTinPeace
  class DefinitionProxy
    class CollectionMethodDefinitions
      def initialize(target)
        @target = target
      end

      def get(method_name, url_template, default_params = {})
        @target.rip_registry[:collection] << { method: :get, name: method_name, url: url_template }
        @target.send(:define_singleton_method, method_name) do |given_params = {}|
          raise RESTinPeace::DefinitionProxy::InvalidArgument unless given_params.respond_to?(:merge)
          params = default_params.merge(given_params)

          call = RESTinPeace::ApiCall.new(api, url_template, self, params)
          call.extend(params.delete(:paginate_with)) if params[:paginate_with]
          call.get
        end
      end
    end
  end
end

