module Helper
  module Teams
    def members_list
      list = members.map do |member|
        if member.class == User
          member_name(member)
        else
          guest_name(member)
        end
      end
      list.each.with_index(1) { |member, i| member.prepend("#{i}.") }
      list.join("\n")
    end

    def random_teams_list(number)
      members_list = members.shuffle
      list = []
      teams = random_team_formation(members_list, number)
      random_team_list_formation(list, teams)
    end

    def teams_list
      list = []
      1.upto(number_of_teams) do |i|
        team_formation(list, i)
      end
      list.join("\n\n")
    end

    def number_of_teams
      [guests.maximum(:team_number), memberships.maximum(:team_number)].max_by(&:to_i)
    end

    def random_team_formation(members, number)
      members_in_team = members.count / number
      extra_members = members.count % number
      list = []
      start = 0
      1.upto(number) do |i|
        last = (i <= extra_members) ? members_in_team.next : members_in_team
        list << members.slice(start, last)
        start = list.flatten.size
      end
      list
    end

    def random_team_list_formation(list, teams)
      teams.each.with_index(1) do |team, i|
        team_list = []
        team.each do |member|
          if member.class == User
            team_list << member_name(member)
            membership(member).update(team_number: i)
          else
            team_list << guest_name(member)
            member.update(team_number: i)
          end
        end
        team_list.each.with_index(1) { |member, i| member.prepend("#{i}.") }
        list << "#{I18n.t('team')} #{i}:\n#{team_list.join("\n")}"
      end
      list.join("\n\n")
    end

    def team_formation(list, team_number)
      team = []
      members.each do |member|
        if member.class == User
          team << (member_name(member)) if team_number == membership(member).team_number
        else
          team << (guest_name(member)) if team_number == member.team_number
        end
      end
      team.each.with_index(1) { |member, i| member.prepend("#{i}.") }
      list << "#{I18n.t('team')} #{team_number}:\n#{team.join("\n")}"
    end

    def member_name(member)
      member.username.present? ? "@#{member.name}" : "#{member.first_name}"
    end

    def guest_name(member)
      member.user.username.present? ? "#{I18n.t('guest')} @#{member.user.name}" : "#{I18n.t('guest')} #{member.user.first_name}"
    end
  end
end
