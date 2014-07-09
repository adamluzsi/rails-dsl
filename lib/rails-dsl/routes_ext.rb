module Rails
  module DSL
    module ActionDispatchRouteEXT

      module Helpers
        class << self

          def process_opts opts={}

            opts = {class: opts} unless opts.class <= ::Hash

            # search for alt keys
            {

                urls:     [:url,:path,{}],
                defaults: [:default,{}],
                ne:       [:exception,:exceptions,:ex,[]],

                get:      [:read],
                post:     [:create],
                put:      [:update],
                delete:   [:delete],

                class:    [:klass,:resource,:resources,:controller]

            }.each do |opts_sym,aliases|
              aliases.each do |alias_sym|
                opts[opts_sym] ||= alias_sym.class == ::Symbol ? opts.delete(alias_sym) || opts.delete(alias_sym.to_s) : alias_sym
              end
              if aliases.last.class != ::Symbol
                raise(ArgumentError,"Invalid object given for #{opts_sym}, should be: #{aliases.last.class}") unless opts[opts_sym].class <= aliases.last.class
              end
            end

            # set defaults
            opts[:ne].map!{|method_name_to_sym| method_name_to_sym.to_s.to_sym }
            [:get,:post,:put,:delete,:options].each{|sym| opts[sym] ||= [] ; opts[sym]= [opts[sym]]  unless opts[sym].class <= ::Array }

            opts[:short_class_name]= opts[:class].to_s.underscore.split('_')[0]
            opts[:class] = if  opts[:class].class == Class
                             opts[:class]

                           else

                             if opts[:class].to_s.include?('_controller')
                               opts[:class].to_s.classify.constantize

                             elsif opts[:class].to_s.include?('Controller')
                               opts[:class].to_s.constantize

                             else
                               begin
                                 opts[:class].to_s.concat('_controller').classify.constantize
                               rescue NameError
                                 if opts[:class].to_s == opts[:class].to_s.downcase
                                   opts[:class].to_s.classify.constantize

                                 else
                                   opts[:class].to_s.constantize

                                 end
                               end

                             end
                           end

            opts[:pim] = opts[:class].public_instance_methods(false).select{|e| !(%W[ ? ! _ ].include?(e.to_s.last)) } - opts[:ne]

            # make setup able method configs
            opts[:pim].each do |sym|

              sym_str= sym.to_s
              {
                  get:    [/_get$/,/^get_/],
                  post:   [/_post$/,/^post_/],
                  put:    [/_put$/,/^put_/],
                  delete: [/_delete$/,/^delete_/]
              }.each do |type,regular_expressions|
                regular_expressions.each do |regex|
                  if sym_str =~ regex
                    opts[type].push(sym)
                    opts[:urls][sym] ||= "/#{sym_str.gsub(regex,"")}"
                  end
                end
              end

            end

            return opts

          end

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

        end
      end

      def mount_by(opts={})
        opts = Helpers.process_opts(opts)

        if opts[:class]
          mount_controller opts
        end

      end

      def mount_controller(opts={})

        opts[:pim].each do |method_name|

          # #> override methods if instance method variable detected, and will passed as input from params
          # begin
          #   var= opts[:class].constantize.instance_method(method_name)
          #   unless var.parameters.select{|ary|(ary[0] ==:req)}.empty?
          #     define_method(method_name) do
          #       var.bind(self).call(*var.parameters.select{|ary|(ary[0] == :req)}.map{|ary| ary[1] }.map{ |param_key| params[param_key] })
          #     end
          #   end
          # end

          #> build path by method name
          method_to_use= nil
          [:get,:post,:put,:delete,:options].each do |pre_spec_method_call_type|
            if opts[pre_spec_method_call_type].include?(method_name)
              method_to_use ||= pre_spec_method_call_type
            end
          end
          method_to_use ||= :match

          url_path = opts[:urls][method_name].nil? ? "/#{method_name}" : opts[:urls][method_name].to_s

          self.__send__ method_to_use,
                        "#{url_path}#{Helpers.array_to_url_params(opts[:params],method_name)}",
                        {to: "#{opts[:short_class_name]}##{method_name}", defaults: opts[:defaults].dup }

        end

        return nil

      end

      def mount_controller_with_render *args

        opts= Rails::DSL::ActionDispatchRouteEXT::Helpers.process_args(*args)
        conv_params= []

        # make last value return as value object rendered as the specific format
        opts[:class].class_eval do

          opts[:pim].each do |sym|



          end

        end

        # mount controller methods
        mount_controller *args,*conv_params #, { defaults: {format: :json} }

        return nil

      end
      alias mount_rendered_controller mount_controller_with_render



    end
  end
end

ActionDispatch::Routing::Mapper.__send__ :include, Rails::DSL::ActionDispatchRouteEXT