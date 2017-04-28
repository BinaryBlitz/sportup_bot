module BotCommand
  class Randomize < Base
    include Helper::Validators

    def should_start?
      text == '/randomize' || text == "/randomize@#{bot_name}"
    end

    def start
      send_message("#{I18n.t('teams_list')}: \n#{event.random_teams_list(event.team_limit)}")
      user.reset_next_bot_command
    end
  end
end
