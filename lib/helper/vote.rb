module Helper
  module Vote
    def begin_vote
      if ((Time.now - date_with_time(ends_at)).to_i / 60).between?(0, 10)
        api.send_message(
          chat_id: chat_id,
          text: "Выберите лучшего игрока матча: \n" \
          "#{users_list.join("\n")} \n\n#{I18n.t('vote_note')}"
        )
      end
    end

    def close_vote
      best_player = memberships.order('votes_count DESC').first
      return close_with_no_members if remained_time <= 0 && best_player.nil?
      if best_player.votes_count > users.count / 2
        api.send_message(
          chat_id: chat_id,
          text: "За #{member_name(best_player.user)} уже отдано #{best_player.votes_count} " \
                'голосов. Он побеждает с явным преимуществом!'
        )
        update(closed: true)
      elsif remained_time <= 0 || memberships.sum(:votes_count) == users.count
        api.send_message(
          chat_id: chat_id,
          text: "Голование закончилось, победил #{member_name(best_player.user)}"
        )
        update(closed: true)
      end
    end

    def close_event_with_no_members
      api.send_message(
        chat_id: chat_id,
        text: "#{I18n.t('end_of_vote')}"
      )
      update(closed: true)
    end

    def close_vote_on_time
      close_vote if remained_time <= 0
    end

    def vote_list
      users_list = users.includes(:memberships).order('memberships.votes_count DESC')
      list = users_list.map { |user| member_name(user) }
      list.each_with_index do |user, i|
        user << " #{membership(users_list[i]).votes_count} голосов"
      end
      list.join("\n")
    end

    def users_list
      list = users.order('id ASC').map { |user| member_name(user) }
      list.each.with_index(1) { |user, i| user.prepend("#{i}.") }
    end

    def upvote(candidate, user)
      membership(candidate).increment(:votes_count, by = 1).save
      membership(user).update(voted: true)
    end
  end
end
