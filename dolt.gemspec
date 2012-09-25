# -*- encoding: utf-8 -*-
dir = File.expand_path(File.dirname(__FILE__))
require File.join(dir, "lib/dolt/version")

module GemSpecHelper
  def self.files(path)
    `cd #{path} && git ls-files`.split("\n").map do |p|
      File.join(path, p)
    end
  end
end

Gem::Specification.new do |s|
  s.name        = "dolt"
  s.version     = Dolt::VERSION
  s.authors     = ["Christian Johansen"]
  s.email       = ["christian@gitorious.org"]
  s.homepage    = "http://gitorious.org/gitorious/dolt"
  s.summary     = %q{Dolt serves git trees and syntax highlighted blobs}
  s.description = %q{Dolt serves git trees and syntax highlighted blobs}

  s.rubyforge_project = "dolt"

  s.add_dependency "eventmachine", "~>1.0"
  s.add_dependency "thin", "~>1.4"
  s.add_dependency "sinatra", "~>1.3"
  s.add_dependency "async_sinatra", "~>1.0"
  s.add_dependency "tilt", "~>1.3"
  s.add_dependency "pygments.rb", "~>0.2"
  s.add_dependency "em_pessimistic", "~>0.1"
  s.add_dependency "builder", "~> 3.1"
  s.add_dependency "em_rugged", "~> 0.1.2"
  s.add_dependency "tzinfo", "~> 0.3"
  s.add_dependency "github-markup", "~> 0.7"
  s.add_dependency "htmlentities", "~> 4.3"
  s.add_dependency "json", "~> 1.7"

  s.add_development_dependency "minitest", "~> 2.0"
  s.add_development_dependency "em-minitest-spec", "~> 1.1"
  s.add_development_dependency "rake", "~> 0.9"
  s.add_development_dependency "mocha"
  s.add_development_dependency "redcarpet"

  s.files         = GemSpecHelper.files(".") + GemSpecHelper.files("vendor/ui")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
