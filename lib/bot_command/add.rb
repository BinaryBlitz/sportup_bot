require './lib/models/guest'

module BotCommand
  class Add < Base

    def should_start?
      text == '/add' || text == "/add@#{bot_name}"
    end

    def start
      if event && event.members_count < event.user_limit
        Guest.create(user: user, event: event)
        send_message(
          "#{username} позвал 1 Гостя на " \
          "#{I18n.l(event.starting_date)} #{event.name} " \
          "Участвует #{event.members_count}/#{event.user_limit}" \
        )
      elsif event && event.members_count == event.user_limit
        send_message("#{I18n.t('full_event')}")
      else
        send_message("#{I18n.t('no_events')}")
      end
      user.reset_next_bot_command
    end
  end
end
