require './lib/models/membership'

module BotCommand
  class Out < Base

    def should_start?
      text == '/out' || text == "/out@#{bot_name}"
    end

    def start
      if event.started?
        send_message("#{I18n.t('started_event')}")
      else
        event.users.destroy(user) if event.users.include?(user)
        send_message(
          "#{username} не будет присутствовать на " \
          "#{I18n.l(event.starting_date)} #{event.name} " \
          "Участвует #{event.members_count}/#{event.user_limit}"
        )
      end
      user.reset_next_bot_command
    end
  end
end
