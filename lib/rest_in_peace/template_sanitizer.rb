require 'rest_in_peace'

module RESTinPeace
  class TemplateSanitizer

    class IncompleteParams < RESTinPeace::DefaultError; end

    def initialize(url_template, params)
      @url_template = url_template
      @params = params
    end

    def url
      return @url if @url
      @url = @url_template.dup
      tokens.each do |token|
        param = @params[token.to_sym]
        raise IncompleteParams, "Unknown parameter for token #{token} found" unless param
        @url.gsub!(%r{:#{token}}, param.to_s)
      end
      @url
    end

    def tokens
      @url_template.scan(%r{:([a-z_]+)}).flatten
    end
  end
end
