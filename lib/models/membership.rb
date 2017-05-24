require 'active_record'
require './lib/bot_command/base'

class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  scope :voted, -> { where(voted:true) }
end
