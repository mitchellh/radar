# Provides a generator to rails 3 to generate the initializer
# file in `config/initializers/radar.rb`. This class is not
# scoped since Rails generates the generator scope based on
# the Ruby scope (e.g. this allows the command to just be
# "rails g radar" instead of "rails g radar:integrations:rails3:radar"
# or some other crazy string).
class RadarGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  desc "Creates a Radar initializer"

  def copy_initializer
    template "radar.rb", "config/initializers/radar.rb"
  end

  def show_readme
    readme "README"
  end
end
