require './lib/models/membership'
require './lib/models/app'
require './lib/models/app_membership'
require 'active_record'

module BotCommand
  class In < Base
    def should_start?
      text == '/in' || text == "/in@#{bot_name}"
    end

    def start
      if event.started?
        send_message(I18n.t('started_event'))
      elsif event.members_count < event.user_limit && event.members.exclude?(user)
        create_member
      elsif event.members.include?(user)
        info_message
      else
        send_message(I18n.t('full_event'))
      end
      user.reset_next_bot_command
    end

    def create_member
      ActiveRecord::Base.transaction do
        Membership.create(user: user, event: event)
        AppMembership.find_or_create_by(user_id: app_user.id) do |membership|
          membership.event_id = AppEvent.find_by(chat_id: event.chat.chat_id).id
        end
        info_message
      end
    end

    def info_message
      send_message(
        "#{username} #{I18n.t('will_attend')} " \
        "#{I18n.l(event.starting_date)} #{event.name} " \
        "#{I18n.t('participates')} #{event.members_count}/#{event.user_limit}"
      )
    end
  end
end
