require './lib/models/guest'

module BotCommand
  class Delete < Base

    def should_start?
      text == '/delete' || text == "/delete@#{bot_name}"
    end

    def start
      if event && user.guests.where(event: event).any?
        user.guests.where(event: event).last.delete
        send_message(
          "@#{user.name} удалил Гостя на " \
          "#{I18n.l(event.starting_date)} #{event.name} " \
          "Участвует #{event.members_count}/#{event.user_limit}"
        )
      else
        send_message("#{I18n.t('no_guests')}")
      end
      user.reset_next_bot_command
    end
  end
end
