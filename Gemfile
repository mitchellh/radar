source "http://rubygems.org"

# Specify the path directly so that files in the examples/
# directory just work.
gemspec :path => File.expand_path("../", __FILE__)

# Additional gems which I don't really want in the gemspec but
# are useful for development
group :development do
  gem "yard", "~> 0.6.1"
  gem "bluecloth"
end

group :examples do
  gem "rack"
  gem "rails", "~> 3.0.0"
  gem "sinatra", "~> 1.0.0"
end
