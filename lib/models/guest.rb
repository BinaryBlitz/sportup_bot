require 'active_record'
require './lib/bot_command/base'

class Guest < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  after_create :send_message

  private

  def send_message
    name.present? ? message(name) : message(nil)
  end

  def message(name)
    base.send_message(
      "#{base.username} #{I18n.t('invited_guest', name: name)} " \
      "#{I18n.l(event.starting_date)} #{event.name} " \
      "#{I18n.t('participates')} #{event.members_count}/#{event.user_limit}",
      chat_id: event.chat.chat_id
    )
  end

  def base
    BotCommand::Base.new(user)
  end
end
