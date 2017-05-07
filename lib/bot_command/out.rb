require './lib/models/membership'

module BotCommand
  class Out < Base
    def should_start?
      text == '/out' || text == "/out@#{bot_name}"
    end

    def start
      if event.started?
        send_message(I18n.t('started_event'))
      else
        event.users.destroy(user) if event.users.include?(user)
      end
      user.reset_next_bot_command
    end
  end
end
