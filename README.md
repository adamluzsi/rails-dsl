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

```ruby

    #> controller
    class PagesController < ApplicationController

      def test

      end

    end

    #> routes.rb

    RailsApp::Application.routes.draw do
      mount_by class: :pages || PageController
    end


```

##### As API behavor

* arguments will be parsed into route :params so the othere side can cache based on url
    * the method actually receive the passed parameter so you can use like in the example

* by extend the method name you can set the methods REST method by the followind endings or beginnings:
    * _get || get_
    * _post || post_
    * _put || put_
    * _delete || delete_

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
    RailsApp::Application.routes.draw do

      # you can still use the Class name too
      mount_by class: :pages

      # defaults can be passed 
      mount_by class: :pages, defaults: { format: :xml }

    end

```

### Rails console Bug Fix

for fixing the annoying error with the rails console,
i added deppendency for the rb-readline gem, witch implement the missing error