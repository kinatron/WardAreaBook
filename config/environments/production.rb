# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

ActionController::Base.cache_store = :file_store, "#{RAILS_ROOT}/public/cache"
# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Mail
# Disable delivery errors, bad email addresses will be ignored
config.action_mailer.raise_delivery_errors = false

# set delivery method to :smtp, :sendmail or :test
config.action_mailer.delivery_method = :smtp

config.action_mailer.smtp_settings = {
  :address => "xxx",
  :authentication => :login,
  :user_name => "xxx",
  :password => "xxx"
}

# these options are only needed if you choose smtp delivery
=begin
config.action_mailer.smtp_settings = {
  :address => "smtp.gmail.com", 
  :port => 587, 
  :authentication => :plain, 
  :enable_starttls_auto => true, 
  :user_name => "xxxx", 
  :password => "xxxx" 
}
=end

# Enable threaded mode
# config.threadsafe!
