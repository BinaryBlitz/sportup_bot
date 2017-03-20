require 'active_record'

class User < ActiveRecord::Base
  has_many :events, through: :memberships
  has_many :memberships, dependent: :destroy
  has_many :guests, dependent: :destroy

  validates :telegram_id, uniqueness: true

  def self.find_by_name(name)
    find_by_first_name(name) || find_by_username(name.gsub('@', ''))
  end

  def next_bot_command(options = {})
    bot_command_data[:method] = options[:method]
    bot_command_data[:class] = options[:class]
    bot_command_data[:event] = options[:event]
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
