# -*- encoding: utf-8 -*-
require File.join("lib/moron/version")

Gem::Specification.new do |s|
  s.name        = "moron"
  s.version     = Moron::VERSION
  s.authors     = ["Christian Johansen"]
  s.email       = ["christian@gitorious.org"]
  s.homepage    = "http://gitorious.org/moron"
  s.summary     = %q{Moron serves git trees and syntax highlighted blobs}
  s.description = %q{Moron serves git trees and syntax highlighted blobs}

  s.rubyforge_project = "moron"

  s.add_dependency "eventmachine", "~>0.12"
  s.add_dependency "thin", "~>1.4"
  s.add_dependency "sinatra", "~>1.3"
  s.add_dependency "async_sinatra", "~>1.0"
  s.add_dependency "tilt", "~>1.3"
  s.add_dependency "pygments.rb", "~>0.2"

  s.add_development_dependency "minitest", "~> 2.0"
  s.add_development_dependency "em-minitest-spec", "~> 1.1"
  s.add_development_dependency "rake", "~> 0.9"
  s.add_development_dependency "mocha"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
