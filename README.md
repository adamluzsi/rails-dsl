rails-dsl
=================

Provide Rails with some extra helpers,

For example for to ActionController::Base a 'duck_params' that parse string values into the right obj,
like:

* "123" to Fixnum
* {"hello":"world"} json into Hash
* "Fri, 25 Jan 2013 20:02:15 +0100" to DateTime obj
* "123.123" to Float obj
* "2011-03-12" to Date obj
* etc etc etc

if you call rails with 'kill' / 'k' command from now on, it will kill the application by it's pid file

    $ rails kill
    #> At pid: 24922 the app is killed with pidfile: /home/asdf/rails_app/tmp/pids/server.pid


### Routing

#### mount controller

* mount a controller public methods as routes.
* the method name will be the path

you can use the following options (name: [aliases])
(the you can specify method(s) rest call type)

* scope:    [:s,:namespace,:path]
* resource: [:r,:class]
* defaults: [:d,:default]
* get:      [:read]
* post:     [:create]
* put:      [:update]
* delete:   [:delete]


```ruby

    #> controller
    class PagesController < ApplicationController

      def test

      end

    end

    #> routes.rb

    HeartShoot::Application.routes.draw do

      mount_controller PagesController
      #> or
      mount_controller :pages

    end

    #> mount not private methods from PagesController

```