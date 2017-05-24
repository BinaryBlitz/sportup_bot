require 'active_record'

class AppEvent < App
  self.table_name = 'events'

  has_many :memberships, class_name: 'AppMembership', foreign_key: 'event_id', dependent: :destroy
end
