# REST in Peace [![Build Status](https://travis-ci.org/ninech/REST-in-Peace.svg)](https://travis-ci.org/ninech/REST-in-Peace) [![Code Climate](https://codeclimate.com/github/ninech/REST-in-Peace.png)](https://codeclimate.com/github/ninech/REST-in-Peace)

A ruby REST client that lets you feel like in heaven when consuming APIs.

![logo](https://raw.githubusercontent.com/ninech/REST-in-Peace/master/images/rest_in_peace.gif)

## Getting Started

1. Add `REST-in-Peace` to your dependencies

        gem 'rest-in-peace'

2. Choose which http adapter you want to use

        gem 'faraday'

## Usage

### HTTP Client Library

There is no dependency on a specific HTTP client library but the client has been tested with [Faraday](https://github.com/lostisland/faraday) only. You can use any other client library as long as it has the same API as Faraday.

### Configuration

#### Attributes

You need to specify all the attributes which should be read out of the parsed JSON. You have to specify whether an attribute
is readonly or writeable:

```ruby
rest_in_peace do
  attributes do
    read :id
    write :name
  end
end
```

#### API Endpoints

You need to define all the API endpoints you want to consume with `RESTinPeace`. Currently the four HTTP Verbs `GET`, `POST`, `PATCH` and `DELETE` are supported.

There are two sections where you can specify endpoints: `resource` and `collection`:

```ruby
rest_in_peace do
  resource do
    get :reload, '/rip/:id'
  end
  collection do
    get :find, '/rip/:id'
  end
end
```

#### HTTP Client Configuration

You need to specify the HTTP client library to use. You can either specify a block (for lazy loading) or a client instance directly.

```ruby
class Resource
  rest_in_peace do
    use_api ->() { Faraday.new(url: 'http://rip.dev') }
  end
end

class ResourceTwo
  rest_in_peace do
    use_api Faraday.new(url: 'http://rip.dev')
  end
end
```

#### Resource

If you define anything inside the `resource` block, it will define a method on the instances of the class:
```ruby
class Resource
  rest_in_peace do
    resource do
      get :reload, '/rip/:id'
      post :create, '/rip'
    end
  end
end

resource = Resource.new(id: 1)
resource.create # calls "POST /rip"
resource.reload # calls "GET /rip/1"
```

**For any writing action (`:post`, `:put`, `:patch`) RESTinPeace will include the writable attributes in the body and `id`.**

#### Collection

If you define anything inside the `collection` block, it will define a method on the class:

```ruby
class Resource
  rest_in_peace do
    collection do
      get :find, '/rip/:id'
      get :find_on_other, '/other/:other_id/rip/:id'
    end
  end
end

resource = Resource.find(id: 1) # calls "GET /rip/1"
resource = Resource.find_on_other(other_id: 42, id: 1337) # calls "GET /other/42/rip/1337"
```

#### Pagination

You can define your own pagination module which will be mixed in when calling the API:

```ruby
class Resource
  rest_in_peace do
    collection do
      get :all, '/rips', paginate_with: MyClient::Paginator
    end
  end
end
```

An example pagination mixin with HTTP headers can be found in the [examples directory](https://github.com/ninech/REST-in-Peace/blob/master/examples) of this repo.

#### Complete Configuration

```ruby
require 'my_client/paginator'
require 'rest_in_peace'

module MyClient
  class Fabric < Struct.new(:id, :name, :ip)
    include RESTinPeace

    rest_in_peace do
      use_api ->() { MyClient.api }
    
      attributes do
        read :id
        write :name
      end

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

## Helpers

### SSL Configuration for Faraday

There is a helper class which can be used to create a Faraday compatible SSL configuration hash (with support for client certificates).

```ruby
ssl_config = {
  "client_cert" => "/etc/ssl/private/client.crt",
  "client_key"  => "/etc/ssl/private/client.key",
  "ca_cert"     => "/etc/ssl/certs/ca-chain.crt"
}

ssl_config_creator = RESTinPeace::SSLConfigCreator.new(ssl_config, :peer)
ssl_config_creator.faraday_options.inspect
# =>
{
  :client_cert => #<OpenSSL::X509::Certificate>,
  :client_key  => Long key is long,
  :ca_file     => "/etc/ssl/certs/ca-chain.crt",
  :verify_mode => 1
}
```