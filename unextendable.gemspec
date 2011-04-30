# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "unextendable/version"

Gem::Specification.new do |s|
  s.name        = "unextendable"
  s.version     = Unextendable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Paul Engel"]
  s.email       = ["paul.engel@holder.nl"]
  s.homepage    = "https://github.com/archan937/unextendable"
  s.summary     = %q{A small gem making unextending extended modules within instances possible}
  s.description = %q{A small gem making unextending extended modules within instances possible}

  s.rubyforge_project = "unextendable"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "shoulda"
  s.add_development_dependency "mocha"
end
