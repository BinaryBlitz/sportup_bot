require './database_connector'
require 'yaml'

class AppConfigurator
  def configure
    setup_i18n
    setup_database
  end

  private

  def setup_i18n
    I18n.load_path = Dir['config/locales/ru.yml']
    I18n.default_locale = :ru
    I18n.backend.load_translations
  end

  def setup_database
    DatabaseConnector.establish_connection
  end
end
