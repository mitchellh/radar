source :gemcutter

# Specify the path directly so that files in the examples/
# directory just work.
gemspec :path => File.expand_path("../", __FILE__)

# Additional gems which I don't really want in the gemspec but
# are useful for development
group :development do
  gem "yard", :git => "http://github.com/lsegal/yard.git"
  gem "bluecloth"

  # For rack integration
  gem "rack"
end
