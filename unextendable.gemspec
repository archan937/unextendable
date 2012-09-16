# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "unextendable/version"

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Engel"]
  gem.email         = ["paul.engel@holder.nl"]
  gem.summary       = %q{A small gem making unextending extended module methods within object instances possible}
  gem.description   = %q{Unextendable originated from the thought of being able to implement the State pattern within object instances using modules. In other words: I wanted object instances to behave dependent on their state using modules. I really want to use modules because they are commonly used to define a set of methods which you can extend within an object instance. Unfortunately, you cannot just unexclude a module. So after searching the web for solutions, I came across Mixology, evil-ruby and StatePattern. But they slightly did not fit the picture. So after doing some research, I came up with Unextendable.}
  gem.homepage      = "https://github.com/archan937/unextendable"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "unextendable"
  gem.require_paths = ["lib"]
  gem.version       = Unextendable::VERSION
end