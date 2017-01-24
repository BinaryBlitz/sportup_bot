require 'active_record'

class User < ActiveRecord::Base
  has_many :events, through: :memberships
  has_many :memberships, dependent: :destroy
  has_many :guests, dependent: :destroy

  validates :telegram_id, uniqueness: true

  def set_next_bot_command(options = {})
    bot_command_data[:method] = options[:method]
    save
  end

  def name
    username || first_name
  end

  def reset_next_bot_command
    self.bot_command_data = {}
    save
  end
end
