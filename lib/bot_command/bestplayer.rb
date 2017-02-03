module BotCommand
  class BestPlayer < Base
    def should_start?
      text == '/bestplayer' || text == "/bestplayer@#{bot_name}"
    end

    def start
      if event.date_with_time(event.ends_at) > Time.now
        send_message("#{I18n.t('not_finished')}")
      else
        send_message(
          "Выберите лучшего игрока матча: \n" \
          "#{event.users_list.join("\n")} \n\n#{I18n.t('vote_note')}" \
          "Распределение голосов на данный момент: \n" \
          "#{event.vote_list} \n\n" \
          "До конца голосования осталось #{event.remained_time / 60} часов #{event.remained_time % 60} минут"
        )
      end
      user.reset_next_bot_command
    end
  end
end
