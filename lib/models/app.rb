require 'active_record'

class App < ActiveRecord::Base
  establish_connection(ENV['HEROKU_POSTGRESQL_COBALT_URL'])
end
