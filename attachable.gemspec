# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "attachable/version"

Gem::Specification.new do |s|
  s.name        = "attachable"
  s.version     = Attachable::VERSION
  s.authors     = ["Brian Michalski"]
  s.email       = ["bmichalski@gmail.com"]
  s.homepage    = "https://github.com/bamnet/attachable"
  s.summary     = %q{A simple set of extensions to support files in a model}
  s.description = %q{Add methods to automatically manage a file as part of a Rails model}

  s.rubyforge_project = "attachable"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
