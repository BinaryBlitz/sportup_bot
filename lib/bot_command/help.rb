module BotCommand
  class Help < Base
    def should_start?
      text == '/help' || text == "/help@#{bot_name}"
    end

    def start
      send_message(I18n.t('help_message'))
      user.reset_next_bot_command
    end
  end
end
