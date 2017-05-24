class AppMembership < App
  self.table_name = 'memberships'

  belongs_to :user
  belongs_to :event
end
