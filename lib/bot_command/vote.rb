module BotCommand
  class Vote < Base
    include Helper::Validators

    def should_start?
      return false if text.nil?
      text.start_with?('/vote') || text.start_with?("/vote@#{bot_name}")
    end

    def start
      number = text.gsub(/\/vote\s+/, '').to_i
      if event.membership(user) && event.membership(user).voted
        send_message("#{I18n.t('voted_already')}")
      elsif event.date_with_time(event.ends_at) > Time.now
        send_message("#{I18n.t('not_finished')}")
      elsif event.members.include?(user) && (text.split('/vote').empty? || text.split("/vote@#{bot_name}").empty?)
        send_message_with_reply("#{I18n.t('number')}")
        user.set_next_bot_command({ method: :number, class: self.class.to_s })
      elsif event.members.include?(user)
        valid_vote?(number, event) do |number|
          vote(number)
        end
      else
        send_message("#{I18n.t('not_member')}")
        user.reset_next_bot_command
      end
      event.close_vote
    end

    def number
      valid_vote?(text, event) do |number|
        vote(number.to_i)
        user.reset_next_bot_command
      end
      event.close_vote
    end

    def vote(number)
      candidate = event.users.order('id ASC')[number-1]
      return voting_restriction if candidate == user
      candidate_name = event.member_name(candidate)
      event.upvote(candidate, user)
      send_message(
        "#{event.member_name(user)} проголосовал за #{candidate_name}. " \
        "У #{candidate_name} #{event.membership(candidate).votes_count}/#{event.users.count} голосов."
      )
      user.reset_next_bot_command
    end

    def voting_restriction
      send_message("#{I18n.t('self_voting')}")
      user.reset_next_bot_command
    end
  end
end
