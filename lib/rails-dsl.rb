require 'rails'
Dir.glob(File.join(File.dirname(__FILE__),'rails-dsl','**','*.{rb,ru}')).each{ |p| require(p) }
