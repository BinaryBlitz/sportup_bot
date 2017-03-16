require './lib/models/membership'

module BotCommand
  class In < Base
    def should_start?
      text == '/in' || text == "/in@#{bot_name}"
    end

    def start
      if event.started?
        send_message(I18n.t('started_event'))
      elsif event.members_count < event.user_limit || event.members.include?(user)
        Membership.create(user: user, event: event) unless event.users.include?(user)
        info_message
      else
        send_message(I18n.t('full_event'))
      end
      user.reset_next_bot_command
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
