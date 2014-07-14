require 'rest_in_peace/template_sanitizer'
require 'rest_in_peace/api_call'

module RESTinPeace
  class DefinitionProxy
    class CollectionMethodDefinitions
      def initialize(target)
        @target = target
      end

      def get(method_name, url_template, default_params = {})
        @target.send(:define_singleton_method, method_name) do |*args|
          if args.last.is_a?(Hash)
            params = default_params.merge(args.pop)
          else
            params = default_params.dup
            tokens = RESTinPeace::TemplateSanitizer.new(url_template, {}).tokens
            tokens.each do |token|
              params.merge!(token.to_sym => args.shift)
            end
          end

          call = RESTinPeace::ApiCall.new(api, url_template, self, params)
          call.extend(params.delete(:paginate_with)) if params[:paginate_with]
          call.get
        end
      end
    end
  end
end

