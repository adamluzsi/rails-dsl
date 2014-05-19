# module Rails
#   module DSL
#
#     module ActionDispatchRouteEXT
#
#       module BlockParser
#
#         def initialize &block
#           @values ||= {}
#           block.call
#         end
#
#         def values
#           return @values
#         end
#
#
#         @@methods ||= [:get,:post,:put,:delete]
#         def method_missing method_name,*args
#
#           Rails.logger.info method_name
#           if @@methods.include?(method_name)
#             @values[method_name]= args[0]
#           end
#
#           return nil
#         end
#
#       end
#
#       def mapping opts={}, &block
#         raise ArgumentError,"options must be hash!" unless opts.class <= Hash
#
#         { scope: [:s,:namespace,:path], resource: [:r,:class], defaults: [:d,:default] }.each do |opts_sym,aliases|
#           aliases.each do |alias_sym|
#             opts[opts_sym] ||= opts.delete(alias_sym) || opts.delete(alias_sym.to_s)
#           end
#         end
#
#         opts[:defaults] ||= {}
#
#         # raise(ArgumentError,"Invalid resource given") if [Symbol,String].select{ |klass| opts[:resource].class <= klass }.empty?
#         raise(ArgumentError,"Invalid defaults given") unless opts[:defaults].class <= ::Hash
#
#         requests= Rails::DSL::ActionDispatchRouteEXT::BlockParser.new(&block)
#
#         generate_calls= lambda { |asd| }
#
#         if !opts[:scope].nil? && opts[:scope].class <= String
#           scope opts[:scope] do
#
#           end
#         end
#
#       end
#
#     end
#   end
# end
#
# ActionDispatch::Routing::Mapper.__send__ :include, Rails::DSL::ActionDispatchRouteEXT