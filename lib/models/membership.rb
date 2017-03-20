require 'active_record'

class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  scope :voted, -> { where(voted:true) }
end
