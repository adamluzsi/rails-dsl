rails-dsl
=================

Provide Rails with some extra helpers,

### Terminal

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

in this mount options

* the methods return value will be sent back parsed object to the requester
* you dont have to set up render options

* arguments will be parsed into route :params so the othere side can cache based on url
    * the method actualy receive the passed parameter so you can use like in the example

* by extend the method name you can set the methods REST method by the followind endings:
    * _get
    * _post
    * _put
    * _delete

```ruby


    #> controller
    class PagesController < ApplicationController

      #> this generate /test1/:hello.:format  path
      def test1 hello
        {hello: hello }
      end

      #> this generate /test2.:format  path
      def test2
        {hello: 'hello' }
      end

      #> POST /test.:format -> default json
      def test2_post
        {hello: 'blabla' }
      end

    end

    #> routes.rb

    HeartShoot::Application.routes.draw do

      # you can still use the Class name too
      mount_controller_with_render :pages

      # or as alias
      mount_rendered_controllers :pages

      # or you can use well defaults key to set up parameters
      # if you prefer the XML as default over JSON output
      mount_rendered_controllers :pages, defaults: { format: :xml }

    end

```

### Rails console Bug Fix

for fixing the annoying error with the rails console,
i added deppendency for the rb-readline gem, witch implement the missing error