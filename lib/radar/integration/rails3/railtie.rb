require "rails"

module Radar
  # The Radar Railtie allows Radar to integrate with Rails 3 by
  # adding generators. **This file is only loaded automatically
  # for Rails 3**.
  class Railtie < Rails::Railtie
    generators do
      require File.expand_path("../generator", __FILE__)
    end
  end
end
