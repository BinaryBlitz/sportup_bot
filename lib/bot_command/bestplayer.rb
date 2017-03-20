module BotCommand
  class BestPlayer < Base
    def should_start?
      text == '/bestplayer' || text == "/bestplayer@#{bot_name}"
    end

    def start
      if event.date_with_time(event.ends_at) > Time.now
        send_message(I18n.t('not_finished'))
      else
        info_message
      end
      user.reset_next_bot_command
    end

    def info_message
      send_message(
        "#{I18n.t('best_player')}: \n" \
        "#{event.users_list.join("\n")} \n\n#{I18n.t('vote_note')}" \
        "#{I18n.t('distribution_of_votes')} \n#{event.vote_list} \n\n" \
        "#{I18n.t('end_of_voting_left')} #{event.remained_time / 60} " \
        "#{I18n.t('hours')} #{event.remained_time % 60} #{I18n.t('minutes')}"
      )
    end
  end
end
