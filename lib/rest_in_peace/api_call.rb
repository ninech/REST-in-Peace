require 'rest_in_peace/template_sanitizer'
require 'rest_in_peace/response_converter'

module RESTinPeace
  class ApiCall
    def initialize(api, url_template, klass, params)
      @api = api
      @url_template = url_template
      @klass = klass
      @params = params
    end

    def get
      response = @api.get(url, @params)
      convert_response(response)
    end

    def post
      response = @api.post(url, @params)
      convert_response(response)
    end

    def patch
      response = @api.patch(url, @params)
      convert_response(response)
    end

    def delete
      response = @api.delete(url, @params)
      convert_response(response)
    end

    def url
      RESTinPeace::TemplateSanitizer.new(@url_template, @params).url
    end

    def convert_response(response)
      RESTinPeace::ResponseConverter.new(response, @klass).result
    end
  end
end
