require './database_connector'
require 'yaml'

class AppConfigurator
  def configure
    setup_i18n
    setup_database
  end

  private

  def setup_i18n
    I18n.load_path += Dir[File.join('config', 'locales', '**', '*.{yml}')]
    I18n.default_locale = :en
    I18n.backend.load_translations
  end

  def setup_database
    DatabaseConnector.establish_connection
    DatabaseConnector.set_timezone
  end
end
