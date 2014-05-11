# coding: utf-8

Gem::Specification.new do |spec|

  spec.name          = "rails-dsl"
  spec.version       = File.open(File.join(File.dirname(__FILE__),"VERSION")).read.split("\n")[0].chomp.gsub(' ','')
  spec.authors       = ["Adam Luzsi"]
  spec.email         = ["adamluzsi@gmail.com"]

  spec.description   = %q{ Provide Rails with some extra helpers, for example for to ApplicationController a 'duck_params' that parse string values into the right_obj like Fixnum or Integer or json to hash  }
  spec.summary       = %q{ provide a duck_params/params_duck call in the ApplicationControllers }

  spec.homepage      = "https://github.com/adamluzsi/#{__FILE__.split(File::Separator).last.split('.').first}"
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"

  spec.add_dependency "str2duck", ">= 1.6.0"
  spec.add_dependency "rails",    ">= 3.0.0"

end
