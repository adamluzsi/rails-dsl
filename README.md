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

#### Mount controller

##### As pages

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

##### As API behavor

in this mount options,
* the methods return value will be sent back parsed object to the requester
* you dont have to set up render options
* arguments will be parsed into route :params so the othere side can cache based on url
** the method actualy receive the passed parameter so you can use like in the example

```ruby


    #> controller
    class PagesController < ApplicationController

      #> this generate /test1/:hello.:format  path
      def test1 hello
        {hello: hello }
      end

      #> this generate /test2/:hello.:format  path
      def test2
        {hello: 'hello' }
      end

    end

    #> routes.rb

    HeartShoot::Application.routes.draw do

      mount_controller_api :pages

      # or
      mount_as_api :pages
      # you can still use the Class name too

      # or
      #> if you prefer the JSON output as default
      mount_as_api :pages, default: { format: :json }

    end

    #> mount not private methods as apit from PagesController

```