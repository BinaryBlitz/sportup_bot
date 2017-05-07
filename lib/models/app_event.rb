require_relative 'app'
require 'active_record'

class AppEvent < App
  table_name = 'events'
end
