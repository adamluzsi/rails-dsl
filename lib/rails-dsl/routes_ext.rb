module Rails
  module DSL

    module ActionDispatchRouteEXT

      module Helpers
        class << self

          def array_to_url_params array,method_name

            return "" unless array.class <= ::Array

            var=nil
            array.each do |ary|

              if ary[0].to_s == method_name.to_s
                var = ary[1]
                break
              end

            end

            if !var.nil?
              return "/:#{var.join('/:')}"
            else
              return ""
            end

          end

          def process_args *args

            opts= args.select{|e|(e.class <= ::Hash)}.reduce( {}, :merge! )

            # search for alt keys
            {

                urls:     [:p,:paths,:url,:u],
                scope:    [:s],
                resource: [:r,:class],
                defaults: [:d,:default],
                params:   [:url_params],
                ne:       [:exception,:exceptions,:ex],

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

            opts[:params]   ||= args.select{|e|(e.class <= ::Array)}
            opts[:params]   ||= []

            opts[:urls]     ||= {}
            opts[:ne]       ||= []

            opts[:ne].map!{|method_name_to_sym| method_name_to_sym.to_s.to_sym }

            [:get,:post,:put,:delete,:options].each{|sym| opts[sym] ||= [] ; opts[sym]= [opts[sym]]  unless opts[sym].class <= ::Array }

            unless opts[:params].class <= ::Array
              raise(ArgumentError,"invalid argument for url params: #{opts[:params]}.\nmust be something like [:method_name,[:url_params]] || [:method_name,:url_params]")
            end

            unless opts[:urls].class <= ::Hash
              raise(ArgumentError,"invalid argument for urls group: #{opts[:urls]}.\nmust be something like {method_name: '/path'}")
            end

            unless opts[:params].empty?

              opts[:params].each{|ary| raise unless ary.size == 2 }
              opts[:params].each{|ary| ary[1]= [ary[1]] unless ary[1].class <= ::Array }

            end

            # validations
            raise(ArgumentError,"Invalid defaults given") unless opts[:defaults].class <= ::Hash

            opts[:short_class_name]= opts[:resource].to_s.underscore.split('_')[0]
            opts[:class] = ( opts[:resource].class == Class ? opts[:resource] : opts[:resource].to_s.concat('_controller').classify.constantize )
            opts[:pim] = opts[:class].public_instance_methods(false).select{|e|(e.to_s.last != '?')} - opts[:ne]

            # make setup able method configs
            opts[:pim].each do |sym|

              sym_str= sym.to_s
              {
                  get:    /_get$/,
                  post:   /_post$/,
                  put:    /_put$/,
                  delete: /_delete$/
              }.each do |type,regex|

                if sym_str =~ regex
                  opts[type].push(sym)
                  opts[:urls][sym] ||= "/#{sym_str.gsub(regex,"")}"
                end

              end

            end

            return opts

          end


        end
      end

      def mount_controller *args

        opts= nil
        if args.size == 1 && args[0].class <= ::Hash
          opts= args[0]
        else
          opts= Rails::DSL::ActionDispatchRouteEXT::Helpers.process_args(*args)
        end

        # helper lambdas

        create_mapping= lambda do

          opts[:pim].each do |method_name|

            method_to_use= nil
            [:get,:post,:put,:delete,:options].each do |pre_spec_method_call_type|
              if opts[pre_spec_method_call_type].include?(method_name)
                method_to_use ||= pre_spec_method_call_type
              end
            end
            method_to_use ||= :get

            url_path = opts[:urls][method_name].nil? ? "/#{method_name}" : opts[:urls][method_name].to_s

            self.__send__ method_to_use,
                          "#{url_path}#{Rails::DSL::ActionDispatchRouteEXT::Helpers.array_to_url_params(opts[:params],method_name)}",
                          {to: "#{opts[:short_class_name]}##{method_name}", defaults: opts[:defaults].dup }

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

        return nil

      end

      def mount_controller_as_api *args

        opts= Rails::DSL::ActionDispatchRouteEXT::Helpers.process_args(*args)
        conv_params= []

        # make last value return as value object rendered as the specific format
        opts[:class].class_eval do

          opts[:pim].each do |sym|

            var= self.instance_method(sym)
            parameters= []

            unless var.parameters.select{|ary|(ary[0] ==:req)}.empty?
              parameters += var.parameters.select{|ary|(ary[0] ==:req)}.map{|ary| ary[1] }
              conv_params.push [ sym, parameters ]
            end

            define_method(sym) do

              value= var.bind(self).call(*parameters.map{ |param_key| params[param_key] })

              respond_to do |format|
                format.html
                format.json { render json:  value }
                format.xml  { render xml:   value }
              end

            end

          end

        end

        # mount controller methods
        mount_controller *args,*conv_params, { defaults: {format: :json} }

        return nil

      end
      alias mount_api mount_controller_as_api

    end
  end
end

ActionDispatch::Routing::Mapper.__send__ :include, Rails::DSL::ActionDispatchRouteEXT