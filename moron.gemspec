# -*- encoding: utf-8 -*-
require File.join("lib/moron/version"

Gem::Specification.new do |s|
  s.name        = "moron"
  s.version     = Moron::VERSION
  s.authors     = ["Christian Johansen"]
  s.email       = ["christian@gitorious.org"]
  s.homepage    = "http://gitorious.org/moron"
  s.summary     = %q{Moron serves git trees and syntax highlighted blobs}
  s.description = %q{Moron serves git trees and syntax highlighted blobs}

  s.rubyforge_project = "moron"

  s.add_dependency "eventmachine", "*"
  s.add_dependency "thin", "*"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
