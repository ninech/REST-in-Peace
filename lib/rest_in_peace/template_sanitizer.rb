require 'rest_in_peace/errors'
require 'addressable/uri'

module RESTinPeace
  class TemplateSanitizer

    class IncompleteParams < RESTinPeace::DefaultError; end

    def initialize(url_template, params, klass)
      @url_template = url_template
      @params = params.dup
      @klass = klass
      @url = nil
    end

    def url
      return @url if @url
      @url = @url_template.dup
      tokens.each do |token|
        param = @params[token.to_sym]
        param ||= @klass.send(token) if @klass.respond_to?(token)
        raise IncompleteParams, "No parameter for token :#{token} found" unless param
        if @params.include?(token.to_sym)
          @url.sub!(%r{:#{token}}, CGI.escape(param.to_s))
        else
          @url.sub!(%r{:#{token}}, Addressable::URI.parse(param.to_s).normalize.to_s)
        end
      end
      @url
    end

    def tokens
      @url_template.scan(%r{:([a-z_]+)}).flatten
    end

    def leftover_params
      @params.delete_if { |param| tokens.include?(param.to_s) }
    end
  end
end
