module BotCommand
  class Teams < Base
    def should_start?
      text == '/teams' || text == "/teams@#{bot_name}"
    end

    def start
      if event.number_of_teams.nil?
        send_message(I18n.t('no_teams'))
      else
        send_message(event.teams_list.to_s)
      end
      user.reset_next_bot_command
    end
  end
end
