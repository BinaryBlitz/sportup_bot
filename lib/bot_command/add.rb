require './lib/models/guest'

module BotCommand
  class Add < Base

    def should_start?
      text == '/add' || text == "/add@#{bot_name}"
    end

    def start
      if event.started?
        send_message("#{I18n.t('started_event')}")
      elsif event.members_count < event.user_limit
        Guest.create(user: user, event: event)
        send_message(
          "#{username} #{I18n.t('invited_guest')} " \
          "#{I18n.l(event.starting_date)} #{event.name} " \
          "#{I18n.t('participates')} #{event.members_count}/#{event.user_limit}" \
        )
      else
        send_message("#{I18n.t('full_event')}")
      end
      user.reset_next_bot_command
    end
  end
end
