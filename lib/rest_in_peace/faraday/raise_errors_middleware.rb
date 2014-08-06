require 'faraday'

module RESTinPeace
  module Faraday
    class RaiseErrorsMiddleware < ::Faraday::Response::Middleware
      CLIENT_ERROR_STATUSES = 400...600

      def on_complete(env)
        case env[:status]
        when 404
          raise ::Faraday::Error::ResourceNotFound, response_values(env)
        when 407
          # mimic the behavior that we get with proxy requests with HTTPS
          raise ::Faraday::Error::ConnectionFailed, %{407 "Proxy Authentication Required "}
        when 422
          # do not raise an error as 422 from a rails app means validation errors
          # and response body contains the validation errors
        when CLIENT_ERROR_STATUSES
          raise ::Faraday::Error::ClientError, response_values(env)
        end
      end

      def response_values(env)
        {
          status: env.status,
          headers: env.response_headers,
          body: env.body,
        }
      end
    end

    ::Faraday::Response.register_middleware rip_raise_errors: RaiseErrorsMiddleware
  end
end
