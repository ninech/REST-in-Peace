module RESTinPeace
  class DefinitionProxy
    class ResourceMethodDefinitions
      def initialize(target)
        @target = target
      end

      def get(method_name, url_template, default_params = {})
        @target.rip_registry[:resource] << { method: :get, name: method_name, url: url_template }
        @target.send(:define_method, method_name) do
          call = RESTinPeace::ApiCall.new(api, url_template, self, to_h)
          call.get
        end
      end

      def patch(method_name, url_template)
        @target.rip_registry[:resource] << { method: :patch, name: method_name, url: url_template }
        @target.send(:define_method, method_name) do
          call = RESTinPeace::ApiCall.new(api, url_template, self, to_h)
          call.patch
        end
      end

      def post(method_name, url_template)
        @target.rip_registry[:resource] << { method: :post, name: method_name, url: url_template }
        @target.send(:define_method, method_name) do
          call = RESTinPeace::ApiCall.new(api, url_template, self, to_h)
          call.post
        end
      end

      def put(method_name, url_template)
        @target.rip_registry[:resource] << { method: :put, name: method_name, url: url_template }
        @target.send(:define_method, method_name) do
          call = RESTinPeace::ApiCall.new(api, url_template, self, to_h)
          call.put
        end
      end

      def delete(method_name, url_template, default_params = {})
        @target.rip_registry[:resource] << { method: :delete, name: method_name, url: url_template }
        @target.send(:define_method, method_name) do |params = {}|
          merged_params = default_params.merge(to_h).merge(params)
          call = RESTinPeace::ApiCall.new(api, url_template, self, merged_params)
          call.delete
        end
      end
    end
  end
end

