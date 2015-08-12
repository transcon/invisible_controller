# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'invisible_controller/version'

Gem::Specification.new do |spec|
  spec.name          = "invisible_controller"
  spec.version       = InvisibleController::VERSION
  spec.authors       = ["Chris Moody"]
  spec.email         = ["cmoody@transcon.com"]

  spec.summary       = %q{RESTful api controllers.}
  spec.description   = %q{When controllers are truely restful, the become more
                          and more empty.  We got to the point where we had many
                          controllers that were just two lines class .. end.
                          At this point it seemed pointless to have controllers.}
  spec.homepage      = "https://github.com/transcon/invisible_controller"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'minitest-reporters',  '>= 1.0.1'
  spec.add_development_dependency 'sqlite3'
end
