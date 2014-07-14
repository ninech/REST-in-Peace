module RESTinPeace
  class TemplateSanitizer
    def initialize(url_template, params)
      @url_template = url_template
      @params = params
    end

    def url
      return @url if @url
      @url = @url_template.dup
      tokens.each do |token|
        @url.gsub!(%r{:#{token}}, @params[token.to_sym].to_s)
      end
      @url
    end

    def tokens
      @url_template.scan(%r{:([a-z_]+)}).flatten
    end
  end
end
