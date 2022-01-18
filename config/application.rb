require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsApp
  class Application < Rails::Application
    config.autoload_paths += Dir[Rails.root.join("app", "models", "{*/}")]
    config.autoload_paths += %W(#{config.root}/lib)
    #config.assets.precompile += ['css/*', 'js/*', 'extras/*', 'font-awesome-css/*', 'DataTables/*']
    config.assets.precompile += ['css/*', 'js/*', 'extras/*', 'font-awesome-css/*']
    config.log_level = :error
    
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    ActiveSupport::JSON::Encoding.use_standard_json_time_format = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
