require_relative 'boot'

require "csv"
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NEDR6
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.time_zone = "Australia/Melbourne"
    config.active_record.default_timezone = :local
  end
end

Rails.configuration.path_to_broadcast_file = "#{ENV['HOME']}/.nsl/broadcast.txt"
