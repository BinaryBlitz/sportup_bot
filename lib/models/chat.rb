require 'active_record'

class Chat < ActiveRecord::Base
  has_many :events, dependent: :destroy

  validates :language, inclusion: %w(ru en), allow_nil: true
  validates :chat_id, uniqueness: true
end
