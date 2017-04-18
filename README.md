# REST in Peace [![Build Status](https://travis-ci.org/ninech/REST-in-Peace.svg)](https://travis-ci.org/ninech/REST-in-Peace) [![Code Climate](https://codeclimate.com/github/ninech/REST-in-Peace.png)](https://codeclimate.com/github/ninech/REST-in-Peace)

A ruby REST client that lets you feel like in heaven when consuming APIs.

![logo](https://raw.githubusercontent.com/ninech/REST-in-Peace/master/images/rest_in_peace.gif)

## Getting Started

1. Add `REST-in-Peace` to your dependencies

        gem 'rest-in-peace'

2. Choose which HTTP client you want to use

        gem 'faraday'
        
3. Choose which HTTP adapter you want to use

        gem 'excon'

## Usage

### HTTP Client Library

This gem depends on the HTTP client library [Faraday](https://github.com/lostisland/faraday). REST-in-Peace has been tested in combination 
with [Faraday](https://github.com/lostisland/faraday) and [Excon](https://github.com/excon/excon) only. 

### Configuration

#### HTTP Client

You need to configure and specify the HTTP client library to use. You can either specify a block (for lazy loading) or a client instance directly.

```ruby
class Resource
  include RESTinPeace
    
  rest_in_peace do
    use_api ->() do
      ::Faraday.new(url: 'http://rip.dev', headers: { 'Accept' => 'application/json' }) do |faraday|
        faraday.request :json
        faraday.response :json
        faraday.adapter :excon # make requests with Excon
      end
    end
  end
end

class ResourceTwo
  include RESTinPeace
  
  rest_in_peace do
    use_api ->() { MyClient.api }
  end
end
```

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

**There must be at least an attribute called `id` to allow REST-in-Peace to work properly.** 

#### API Endpoints

You need to define all the API endpoints you want to consume with `REST-in-Peace`. Currently the five verbs `GET`, `POST`, `PUT`, `PATCH` and `DELETE` are supported.

There are two sections where you can specify endpoints: `resource` and `collection`. `collection` supports the HTTP verb `GET` only.

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

#### Resource

If you define anything inside the `resource` block, it will define a method on the instances of the class:
```ruby
class Resource
  include RESTinPeace
  
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

#### Collection

If you define anything inside the `collection` block, it will define a method on the class:

```ruby
class Resource
  include RESTinPeace
  
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

#### HTTP Verb differences

Depending on the given HTTP verb, a different set of attributes will be used as payload and query parameters.

HTTP Verb           | passed | all | only changed and id | only id
------------------- | :----: | :-: | :-----------------: | :-----:
`GET` on collection | ✔      | ✘   | ✘                   | ✘
`GET` on resource   | ✘      | ✔   | ✘                   | ✘
`POST`              | ✘      | ✔   | ✘                   | ✘
`PUT`               | ✘      | ✔   | ✘                   | ✘
`PATCH`             | ✘      | ✘   | ✔                   | ✘
`DELETE`            | ✘      | ✘   | ✘                   | ✔

#### Pagination

You can define your own pagination module which will be mixed in when calling the API:

```ruby
class Resource
  include RESTinPeace
  
  rest_in_peace do
    collection do
      get :all, '/rips', paginate_with: MyClient::Paginator
    end
  end
end
```

An example pagination mixin with HTTP headers can be found in the [examples directory](https://github.com/ninech/REST-in-Peace/blob/master/examples) of this repo.

#### ActiveModel Support

For easy interoperability with Rails, there is the ability to include ActiveModel into your class. To enable this support, follow these steps:

* Define a `create` method (To be called for saving new objects)
* Define a `save` method (To be called for updates)
* Call `acts_as_active_model` **after** your *API endpoints* and *attribute* definitions

##### Example

```ruby
require 'rest_in_peace'
require 'faraday'

module MyClient
  class Fabric
    include RESTinPeace

    rest_in_peace do
      use_api ->() { MyClient.api }
    
      attributes do
        read :id
        write :name
      end

      resource do
        post :create, '/fabrics'
        patch :save, '/fabrics/:id'
      end
      
      acts_as_active_model
    end
  end
end
```

### Complete Configurations

#### Configured Fabric class with all dependencies

```ruby 
require 'my_client/paginator'
require 'rest_in_peace'
require 'faraday'

module MyClient
  class Fabric
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

      acts_as_active_model
    end
  end
end
```

#### Configured Fabric class using Faraday

```ruby
require 'my_client/paginator'
require 'rest_in_peace'
require 'faraday'

module MyClient
  class Fabric
    include RESTinPeace

    rest_in_peace do
      use_api ->() do
        ::Faraday.new(url: 'http://localhost:3001', headers: { 'Accept' => 'application/json' }) do |faraday|
          faraday.request :json
          faraday.response :json
          faraday.adapter :excon
        end
      end
    
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

      acts_as_active_model
    end
  end
end
```

#### CRUD options example of use
```ruby
# CREATE
fabric = MyClient::Fabric.new(name: 'my new fabric')
fabric.create # calls "POST /fabrics"
fabric.reload # calls "GET /fabrics/1"

# READ
last_fabric = MyClient::Fabric.find(id: fabric.id) # calls "GET /fabrics/1"

# UPDATE - first way
updated_fabric = last_fabric.update_attributes(name: 'first way fabric')
updated_fabric.save # calls "PATCH /fabrics/1"

# UPDATE - second way 
updated_fabric = last_fabric.update(name: 'second way fabric') # calls "PATCH /fabrics/1"

# DELETE
updated_fabric.destroy # calls "DELETE /fabrics/1"
```
Method `update_attributes` sets updated value, `save` method stores all changes. This change can be done with calling 
single line method `update` which do the both things. 

## Helpers

### SSL Configuration for Faraday

There is a helper class which can be used to create a Faraday compatible SSL configuration hash (with support for client certificates).

```ruby
ssl_config = {
  "client_cert" => "/etc/ssl/private/client.crt",
  "client_key"  => "/etc/ssl/private/client.key",
  "ca_cert"     => "/etc/ssl/certs/ca-chain.crt"
}

ssl_config_creator = RESTinPeace::Faraday::SSLConfigCreator.new(ssl_config, :peer)
ssl_config_creator.faraday_options.inspect
# =>
{
  :client_cert => #<OpenSSL::X509::Certificate>,
  :client_key  => Long key is long,
  :ca_file     => "/etc/ssl/certs/ca-chain.crt",
  :verify_mode => 1
}
```

### Faraday Middleware: RIP Raise Errors

This middleware is mostly equivalent to [this one](https://github.com/lostisland/faraday/blob/cf549f4d883a3cae15db0d835628daa33f6f3a2b/lib/faraday/response/raise_error.rb) but it does not raise an error when the HTTP status code is `422` as this code is used to return validation errors.

```ruby
Faraday.new do |faraday|
  # ...
  faraday.response :rip_raise_errors
  # ...
end
```

## About

This gem is currently maintained and funded by [nine.ch](https://nine.ch).

[![nine.ch](https://blog.nine.ch/assets/logo.png)](https://nine.ch)

We run your Linux server infrastructure – without interruptions, around the clock.
