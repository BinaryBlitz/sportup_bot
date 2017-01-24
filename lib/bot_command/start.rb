module BotCommand
  class Start < Base
    def should_start?
      text == '/start' || text == "/start@#{bot_name}"
    end

    def start
      send_message(I18n.t('start_message'))
      user.reset_next_bot_command
    end
  end
end
