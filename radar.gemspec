# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'radar/version'

Gem::Specification.new do |s|
  s.name        = "radar"
  s.version     = Radar::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mitchell Hashimoto"]
  s.email       = ["mitchell.hashimoto@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/radar"
  s.summary     = "Easily report errors in your libraries to the cloud."
  s.description = "Radar provides a drop-in solution to catching and reporting errors to a radar server in the cloud."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "radar"

  s.add_dependency "json", ">= 1.4.6"

  s.add_development_dependency "bundler", ">= 1.0.0.rc.5"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "mocha"
  s.add_development_dependency "yard"
  s.add_development_dependency "bluecloth"
  s.add_development_dependency "rake"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").select{|f| f =~ /^bin/}
  s.require_path = 'lib'
end
