require_relative 'boot'

require "csv"
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module V6021
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # See also confug.ru change to apply relative_url_root.
    config.action_controller.relative_url_root = "/nsl/hub"
    config.time_zone = "Australia/Melbourne"
    config.active_record.default_timezone = :local
  end
end
