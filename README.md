Tamashii [![Gem Version](https://badge.fury.io/rb/tamashii.svg)](https://badge.fury.io/rb/tamashii) [![Build Status](https://travis-ci.org/tamashii-io/tamashii.svg?branch=master)](https://travis-ci.org/tamashii-io/tamashii) [![Test Coverage](https://codeclimate.com/github/tamashii-io/tamashii/badges/coverage.svg)](https://codeclimate.com/github/tamashii-io/tamashii/coverage) [![Code Climate](https://codeclimate.com/github/tamashii-io/tamashii/badges/gpa.svg)](https://codeclimate.com/github/tamashii-io/tamashii)
===

Tamashii is a package designed for IoT. You can write the WebSocket server and client easily by using this gem.


## Installation

Add the following code to your `Gemfile`

```ruby
gem 'tamashii'
```

And then execute:
```ruby
$ bundle install
```

Or install it yourself with:
```ruby
$ gem install tamashii
```

## Usage

There are two section in Tamashii, Server and Client, is responsible for the WebSocket server and client, respectively.

### Server

Server section is a server designed based on Rack, it can not only be easily compatible with the web server, such as Puma, Passenger, but also be used as a module in the Rails and other projects.

To start the server, generate `config.ru` and add the following code to it.

```ruby
require 'tamashii/server'

run Tamashii::Server::Base.new
```

Then, you can start the server with:

    $ rackup
If you want to start the server with other web server, such as Puma:

    $ puma

> You can refer to the project in [tamashii-manager](https://github.com/5xRuby/tamashii-manager) in the IoT server application.

#### Connection

In Tamashii, we only need to focus on how to connect with Websocket users to exchange information, on the process of multi-process web server problems have been resolved in Tamashii.

We can create a `Client` object to handle the behavior of each user.

```ruby
Tamashii::Server.config do |config|
  config.connection_class = Client
end
```

In `Client` , there are four events that need to be handled.

* `on_open` : when the user is connected to the server
* `on_message` : when the server receives the message from user
* `on_error` : when the server gets an error
* `on_close` : when the connection is shut down

In most cases, we only need to deal with parts of `on_message` , the other events can be handled as needed.

```ruby
class Client
    def on_message(data)
        # Processing for the received Data (Binary)
    end
end
```

By default Tamashii will broadcast the received message to other clients automatically.


### Client

The client is in another repository: [tamashii-client](https://github.com/tamashii-io/tamashii-client)


## Development

To get the source code

    $ git clone git@github.com:tamashii-io/tamashii.git

Initialize the development environment

    $ ./bin/setup

Run the spec

    $ rspec

Installation the version of development on localhost

    $ bundle exec rake install

## Contribution

Please report to us on [GitHub](https://github.com/tamashii-io/tamashii) if there is any bug or suggested modified.

The project was developed by [5xruby Inc.](https://5xruby.tw/)

