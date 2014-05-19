begin

  require 'str2duck'
  require 'action_controller'

  module Rails
    module DSL

      module ActionControllerEXT

        def params_duck

          @duck_params_origin ||= params.dup
          @duck_params_cache  ||= nil

          if params == @duck_params_origin && !@duck_params_cache.nil?

            return @duck_params_cache

          else

            @duck_params_cache= params.dup
            @duck_params_origin= params.dup

            params.each do |k,v|
              @duck_params_cache[k]=( ::Str2Duck.parse(v) ) if v.class <= String
            end

            return @duck_params_cache

          end

        end
        alias duck_params params_duck

      end

    end
  end

  ActionController::Base.__send__ :include, Rails::DSL::ActionControllerEXT

rescue LoadError
end