module BotCommand
  class Vote < Base
    include Helper::Buttons

    def should_start?
      return false if text.nil?
      text == '/vote' || text == "/vote@#{bot_name}"
    end

    def start
      if event.date_with_time(event.ends_at) > Time.now
        send_message(I18n.t('not_finished'))
      else
        event&.begin_vote_message
      end
    end

    def vote
      if event&.membership(user)&.voted
        answer_callback_query(I18n.t('voted_already'))
      elsif event.date_with_time(event.ends_at) > Time.now
        answer_callback_query(I18n.t('not_finished'))
      elsif event.members.include?(user)
        vote_info
      else
        answer_callback_query(I18n.t('not_member'))
      end
      user.reset_next_bot_command
    end

    def vote_info
      candidate = User.find_by_name(text_from_button)
      return voting_restriction if candidate == user
      event.upvote(candidate, user)
      edit_vote_message
      event.close_vote
    end

    def edit_vote_message
      edit_message_text(
        event&.begin_vote_text,
        inline_buttons(candidates_list(users_names))
      )
    end

    def voting_restriction
      answer_callback_query(I18n.t('self_voting'))
      user.reset_next_bot_command
    end

    def users_names
      event.users.order(id: :asc).map(&:name)
    end
  end
end
