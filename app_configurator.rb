require './database_connector'
require 'timezone'
require 'yaml'
require 'geocoder'

class AppConfigurator
  def configure
    setup_i18n
    setup_database
    setup_timezone
    setup_geocoder
  end

  private

  def setup_i18n
    I18n.load_path += Dir[File.join('config', 'locales', '**', '*.{yml}')]
    I18n.default_locale = :en
    I18n.backend.load_translations
  end

  def setup_database
    DatabaseConnector.establish_connection
  end

  def setup_timezone
    Timezone::Lookup.config(:geonames) do |c|
      c.username = ENV["GEONAMES_NAME"]
      c.offset_etc_zones = true
    end
  end

  def setup_geocoder
    Geocoder.configure(
      lookup: :google, api_key: ENV["GOOGLE_API_KEY"],
      use_https: true, ip_lookup: :maxmind
    )
  end
end
