module BotCommand
  class Vote < Base
    include Helper::Buttons

    def should_start?
      return false if text.nil?
      text.start_with?('/vote') || text.start_with?("/vote@#{bot_name}")
    end

    def start
      event&.begin_vote_message
    end

    def vote
      if event&.membership(user)&.voted
        send_message(I18n.t('voted_already'))
      elsif event.date_with_time(event.ends_at) > Time.now
        send_message(I18n.t('not_finished'))
      elsif event.members.include?(user)
        vote_info
      else
        send_message(I18n.t('not_member'))
        user.reset_next_bot_command
      end
    end


    def vote_info
      candidate = User.find_by_name(text_from_button)
      return voting_restriction if candidate == user
      candidate_name = event.member_name(candidate)
      event.upvote(candidate, user)
      send_message(
        "#{event.member_name(user)} #{I18n.t('voted_for')} #{candidate_name}. " \
        "#{I18n.t('preposition', default: '')}#{candidate_name} #{I18n.t('has', default: '')} " \
        "#{event.membership(candidate).votes_count}/#{event.users.count} #{I18n.t('votes')}."
      )
      edit_vote_message
      user.reset_next_bot_command
      event.close_vote
    end

    def edit_vote_message
      edit_message_text(
        event&.begin_vote_text,
        inline_buttons(candidates_list(event.users.order(id: :asc).map(&:name)))
      )
    end

    def voting_restriction
      send_message(I18n.t('self_voting'))
      user.reset_next_bot_command
    end
  end
end
