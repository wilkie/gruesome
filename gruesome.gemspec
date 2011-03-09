# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gruesome/version"

Gem::Specification.new do |s|
  s.name        = "gruesome"
  s.version     = Grue::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dave Wilkinson"]
  s.email       = ["wilkie05@gmail.com"]
  s.homepage    = "http://github.com/wilkie/gruesome"
  s.summary     = %q{An Interactive Fiction client that can play/read interactive stories}
  s.description = %q{Reads and executes various interactive fiction technologies and helps easily download new stories from other sources on the Internet.}

  s.rubyforge_project = "gruesome"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"

  s.add_dependency "bit-struct"
end
