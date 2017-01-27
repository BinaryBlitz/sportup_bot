module BotCommand
  class Teams < Base
    def should_start?
      text == '/teams' || text == "/teams@#{bot_name}"
    end

    def start
      if event
        send_message("#{event.teams_list}")
      else
        send_message("#{I18n.t('no_events')}")
      end
      user.reset_next_bot_command
    end
  end
end
