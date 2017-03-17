require 'active_record'

class DatabaseConnector
  class << self
    def establish_connection
      configuration = YAML.load(IO.read(database_config_path))[(ENV['BOT_ENV'] || 'development')]
      ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || configuration)
    end

    private

    def database_config_path
      'config/database.yml'
    end
  end
end
