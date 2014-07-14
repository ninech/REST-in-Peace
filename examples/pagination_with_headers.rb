module MyClient
  module Paginator
    def get
      Enumerator.new do |yielder|
        @params.merge!(page: 1)
        result = api.get(url, @params)
        current_page = result.env.response_headers['X-Page'].to_i
        total_pages = result.env.response_headers['X-Total-Pages'].to_i

        loop do
          # Yield the results we got in the body.
          result.body.each do |item|
            yielder << @klass.new(item)
          end

          # Only make a request to get the next page if we have not
          # reached the last page yet.
          raise StopIteration if current_page == total_pages
          @params.merge!(page: current_page + 1)
          result = api.get(url, @params)
          current_page = result.env.response_headers['X-Page'].to_i
        end
      end
    end
  end
end
