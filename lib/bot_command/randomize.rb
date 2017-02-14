module BotCommand
  class Randomize < Base
    include Helper::Validators

    def should_start?
      return false if text.nil?
      text.start_with?('/randomize') || text.start_with?("/randomize@#{bot_name}")
    end

    def start
      if text.split('/randomize').empty? || text.split("/randomize@#{bot_name}").empty?
        send_message_with_reply("#{I18n.t('number_of_teams')}")
        user.set_next_bot_command({ method: :number, class: self.class.to_s })
      else
        number = text.gsub(/\/randomize\s+/, '').to_i
        valid_number_of_teams?(number, event) do |number|
          send_message("#{I18n.t('teams_list')}: \n#{event.random_teams_list(number)}")
          user.reset_next_bot_command
        end
      end
    end

    def number
      valid_number_of_teams?(text, event) do |number|
        send_message("#{I18n.t('teams_list')}: \n#{event.random_teams_list(number.to_i)}")
        user.reset_next_bot_command
      end
    end
  end
end
