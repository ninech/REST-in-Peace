module RESTinPeace
  class DefinitionProxy
    class ResourceMethodDefinitions
      def initialize(target)
        @target = target
      end

      def get(method_name, url_template, default_params = {})
        @target.rip_registry[:resource] << { method: :get, name: method_name, url: url_template }
        @target.send(:define_method, method_name) do
          call = RESTinPeace::ApiCall.new(api, url_template, self, hash_for_updates)
          call.get
        end
      end

      def patch(method_name, url_template)
        @target.rip_registry[:resource] << { method: :patch, name: method_name, url: url_template }
        @target.send(:define_method, method_name) do
          call = RESTinPeace::ApiCall.new(api, url_template, self, hash_for_updates)
          call.patch
        end
      end

      def post(method_name, url_template)
        @target.rip_registry[:resource] << { method: :post, name: method_name, url: url_template }
        @target.send(:define_method, method_name) do
          call = RESTinPeace::ApiCall.new(api, url_template, self, hash_for_updates)
          call.post
        end
      end

      def put(method_name, url_template)
        @target.rip_registry[:resource] << { method: :put, name: method_name, url: url_template }
        @target.send(:define_method, method_name) do
          call = RESTinPeace::ApiCall.new(api, url_template, self, hash_for_updates)
          call.put
        end
      end

      def delete(method_name, url_template)
        @target.rip_registry[:resource] << { method: :delete, name: method_name, url: url_template }
        @target.send(:define_method, method_name) do
          call = RESTinPeace::ApiCall.new(api, url_template, self, id: id)
          call.delete
        end
      end
    end
  end
end

