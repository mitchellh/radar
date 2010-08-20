require File.expand_path("../lib/radar/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "radar"
  s.version     = Radar::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mitchell Hashimoto"]
  s.email       = ["mitchell.hashimoto@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/radar"
  s.summary     = "Easily catch and report errors in your Ruby libraries and applications any way you want!"
  s.description = "Radar provides a drop-in solution to catching and reporting errors in your libraries and applications."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "radar"

  s.add_dependency "json", ">= 1.4.6"

  s.add_development_dependency "bundler", ">= 1.0.0.rc.5"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "mocha"
  s.add_development_dependency "rake"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
