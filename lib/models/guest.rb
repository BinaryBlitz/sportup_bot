require 'active_record'
require './lib/bot_command/base'

class Guest < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  after_create :send_message

  private

  def send_message
    return message_form_app if from_app?
    name.present? ? message(name) : message(nil)
  end

  def message(name)
    BotCommand::Base.new.send_message(
      "#{user.name} #{I18n.t('invited_guest', name: name)} " \
      "#{I18n.l(event.starting_date)} #{event.name} " \
      "#{I18n.t('participates')} #{event.members_count}/#{event.user_limit}" \
    )
  end

  def message_from_app
    BotCommand::Base.new.send_message(
      "#{I18n.t('guest')} #{user.name} #{I18n.t('entered_from_app')}. " \
      "#{I18n.t('participates')} #{event.members_count}/#{event.user_limit}" \
    )
  end
end
