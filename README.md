# REST in Peace

A simple REST Client.

![logo](https://raw.githubusercontent.com/ninech/REST-in-Peace/master/images/rest_in_peace.gif)

## Usage



```ruby
require 'my_client/paginator'
require 'rest_in_peace'

module MyClient
  class Fabric < Struct.new(:id, :name, :ip)
    include RESTinPeace

      define_api_methods do
        resource do
          patch :save, '/fabrics/:id'
          post :create, '/fabrics'
          delete :destroy, '/fabrics/:id'
          get :reload, '/fabrics/:id'
        end

        collection do
          get :all, '/fabrics', paginate_with: MyClient::Paginator
          get :find, '/fabrics/:id'
        end
      end
    end
  end
end
```
