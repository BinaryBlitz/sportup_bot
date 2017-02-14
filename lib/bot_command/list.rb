module BotCommand
  class List < Base

    def should_start?
      text == '/list' || text == "/list@#{bot_name}"
    end

    def start
      send_message(
        "#{I18n.l(event.starting_date)} #{event.name} \n" \
        "#{event.address} \n" \
        "#{event.starts_at.strftime("%H:%M")} - #{event.ends_at.strftime("%H:%M")} \n" \
        "#{event.user_limit} #{I18n.t('participants')} \n" \
        "#{I18n.t('goes')} #{event.members_count}/#{event.user_limit}: \n" \
        "#{event.members_list}"
      )
      user.reset_next_bot_command
    end
  end
end
