module Rails
  module DSL

    module ActionDispatchRouteEXT

      module Helpers
        class << self

          def process_args *args

            opts= args.select{|e|(e.class <= ::Hash)}.reduce( {}, :merge! )

            # search for alt keys
            {

                scope:    [:s,:namespace,:path],
                resource: [:r,:class],
                defaults: [:d,:default],

                get:      [:read],
                post:     [:create],
                put:      [:update],
                delete:   [:delete]

            }.each do |opts_sym,aliases|
              aliases.each do |alias_sym|
                opts[opts_sym] ||= opts.delete(alias_sym) || opts.delete(alias_sym.to_s)
              end
            end

            # set defaults
            opts[:defaults] ||= {}
            opts[:resource] ||= args.select{|e|([::Class,::String,::Symbol].include?(e.class))}[0]

            [:get,:post,:put,:delete,:options].each{|sym| opts[sym] ||= [] ; opts[sym]= [opts[sym]]  unless opts[sym].class <= ::Array }

            # validations
            raise(ArgumentError,"Invalid defaults given") unless opts[:defaults].class <= ::Hash

            opts[:short_class_name]= opts[:resource].to_s.underscore.split('_')[0]
            opts[:class]      = ( opts[:resource].class == Class ? opts[:resource] : opts[:resource].to_s.concat('_controller').classify.constantize )


            return opts

          end


        end
      end

      def mount_controller *args

        opts= Rails::DSL::ActionDispatchRouteEXT::Helpers.process_args(*args)

        # helper lambdas

        create_mapping= lambda do

          opts[:class].public_instance_methods(false).each do |method_name|

            method_to_use= nil
            [:get,:post,:put,:delete,:options].each do |pre_spec_method_call_type|
              if opts[pre_spec_method_call_type].include?(method_name)
                method_to_use ||= pre_spec_method_call_type
              end
            end
            method_to_use ||= :get

            self.__send__ method_to_use,"/#{method_name}",{to: "#{opts[:short_class_name]}##{method_name}"}.merge({defaults: opts[:defaults]})

          end

        end

        # make scope
        if !opts[:scope].nil? && opts[:scope].class <= String
          self.scope opts[:scope] do
            create_mapping.call
          end
        else
          create_mapping.call
        end

      end

      # def mount_controller_api *args
      #   opts= Rails::DSL::ActionDispatchRouteEXT::Helpers.process_args(*args)
      #
      #   # respond_to do |format|
      #   #   format.html
      #   #   format.json{
      #   #     render :json => {hello: 'world'}
      #   #   }
      #   # end
      #
      # end
      # alias mount_controller_as_api mount_controller_api

    end
  end
end

ActionDispatch::Routing::Mapper.__send__ :include, Rails::DSL::ActionDispatchRouteEXT