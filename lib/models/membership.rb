require 'active_record'
require './lib/bot_command/base'

class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  after_create :send_create_message
  after_destroy :send_exit_message

  scope :voted, -> { where(voted:true) }

  private

  def send_participation_message
    info_message = from_app? ? participation_message_from_app : participation_message
    BotCommand::Base.new.send_message(info_message)
  end

  def send_exit_message
    info_message = from_app? ? exit_message_from_app : exit_message
    BotCommand::Base.new.send_message(info_message)
  end

  def exit_message
    "#{user.name} #{I18n.t('will_not_attend')} " \
    "#{I18n.l(event.starting_date)} #{event.name} " \
    "#{I18n.t('participates')} #{event.members_count}/#{event.user_limit}"
  end

  def exit_message_from_app
    "#{user.name} #{I18n.t('left_from_app')} " \
    "#{I18n.t('participates')} #{event.members_count}/#{event.user_limit}"
  end

  def participation_message
    "#{user.name} #{I18n.t('will_attend')} " \
    "#{I18n.t('participates')} #{event.members_count}/#{event.user_limit}"
  end

  def participation_message_from_app
    "#{user.name} #{I18n.t('entered_from_app')}. " \
    "#{I18n.t('participates')} #{event.members_count}/#{event.user_limit}" \
  end
end
