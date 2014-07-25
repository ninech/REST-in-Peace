require 'rest_in_peace/errors'

module RESTinPeace
  class TemplateSanitizer

    class IncompleteParams < RESTinPeace::DefaultError; end

    def initialize(url_template, params)
      @url_template = url_template
      @params = params.dup
    end

    def url
      return @url if @url
      @url = @url_template.dup
      tokens.each do |token|
        param = @params.delete(token.to_sym)
        raise IncompleteParams, "Unknown parameter for token :#{token} found" unless param
        @url.sub!(%r{:#{token}}, param.to_s)
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
