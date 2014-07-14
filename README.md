# REST in Peace [![Build Status](https://travis-ci.org/ninech/REST-in-Peace.svg)](https://travis-ci.org/ninech/REST-in-Peace)

A ruby REST client that lets you feel like in heaven when consuming APIs.

![logo](https://raw.githubusercontent.com/ninech/REST-in-Peace/master/images/rest_in_peace.gif)

## Getting Started

1. Add `REST-in-Peace` to your dependencies

        gem 'rest-in-peace'

2. Choose which http adapter you want to use

        gem 'faraday'

## Usage

```ruby
require 'my_client/paginator'
require 'rest_in_peace'

module MyClient
  class Fabric < Struct.new(:id, :name, :ip)
    include RESTinPeace

    rest_in_peace do
      use_api ->() { MyClient.api }
    
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
```
