# This creates a Radar application for your Rails app. Use the block
# to configure it. For detailed documentation, please see the user guide
# online at: http://radargem.com/file.user_guide.html
Radar::Application.new(:<%= Rails.application.class.to_s.underscore.tr('/', '_') %>) do |app|
  # ==> Reporter Configuration
  # Configure any reporters here. Reporters tell Radar how to report exceptions.
  # This may be to a file, to a server, to a stream, etc. At least one reporter
  # is required for Radar to do something with your exceptions. By default,
  # Radar reports to the Rails logger. Change this if you want to report to
  # a file, a server, etc.
  app.reporters.use :logger, :log_object => Rails.logger, :log_level => :error

  # Tell Radar to integrate this application with Rails 3.
  app.integrate :rails3
end
