# -*- encoding: utf-8 -*-
dir = File.expand_path(File.dirname(__FILE__))

module GemSpecHelper
  def self.files(path)
    `cd #{path} && git ls-files`.split("\n").map do |p|
      File.join(path, p)
    end
  end
end

Gem::Specification.new do |s|
  s.name        = "dolt"
  s.version     = "0.9.0"
  s.authors     = ["Christian Johansen"]
  s.email       = ["christian@gitorious.org"]
  s.homepage    = "http://gitorious.org/gitorious/dolt"
  s.summary     = %q{Dolt serves git trees and syntax highlighted blobs}
  s.description = %q{Dolt serves git trees and syntax highlighted blobs}

  s.rubyforge_project = "dolt"

  s.add_dependency "libdolt", "~>0.14"
  s.add_dependency "thin", "~>1.4"
  s.add_dependency "sinatra", "~>1.0"
  s.add_dependency "async_sinatra", "~>1.0"
  s.add_dependency "tiltout", "~>1.4"
  s.add_dependency "json", "~>1.5"

  s.add_development_dependency "minitest", "~> 2.0"
  s.add_development_dependency "em-minitest-spec", "~> 1.1"
  s.add_development_dependency "rake", "~> 0.9"

  s.files         = GemSpecHelper.files(".") + GemSpecHelper.files("vendor/ui")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
