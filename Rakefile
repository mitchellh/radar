require 'rubygems'
require 'bundler/setup'
require 'rake/testtask'
require 'yard'
Bundler::GemHelper.install_tasks

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
end

YARD::Rake::YardocTask.new do |t|
  # t.files   = ['lib/**/*.rb', OTHER_PATHS]
  # t.options = ['--any', '--extra', '--opts']
end
