require 'active_record'
require 'telegram/bot'
require './lib/helper'
require './environment'

class Event < ActiveRecord::Base
  include Helper::Date
  include Environment

  default_scope { where(closed: false) }

  has_many :users, through: :memberships
  has_many :memberships, dependent: :destroy
  has_many :guests, dependent: :destroy

  scope :closed, -> { where(closed: true) }

  def close
    if close_time?
      update(closed: true)
      Telegram::Bot::Api.new(token).send_message(
        chat_id: chat_id,
        text: "#{I18n.t('farewell_message')}"
      )
    end
  end

  def members_count
    users.count + guests.count
  end

  def members
    users + guests
  end

  def members_list
    members.map.with_index(1) do |member, i|
      if member.class == User
        "#{i}.@#{member.name}"
      else
        "#{i}.Гость @#{member.user.name}"
      end
    end.join("\n")
  end

  def random_teams_list(number)
    members_in_team = members.count / number
    members_list = members.shuffle
    list = []
    1.upto(number) do |i|
      random_team_formation(members_list, list, members_in_team, i)
    end
    list.join("\n")
  end

  def teams_list
    number_of_teams = guests.maximum(:team_number)
    list = []
    1.upto(number_of_teams) do |i|
      team_formation(members, list, i)
    end
    list.join("\n")
  end

  def starts_at_with_date
    starts_at = I18n.l(self.starts_at, format: :short)
    add_time_to_date(starting_date, starts_at)
  end

  private

  def random_team_formation(members, list, members_in_team, team_number)
    team = []
    members.last(members_in_team).each.with_index(1) do |member, j|
      if member.class == User
        team << "#{j}.@#{member.name}"
        membership(member).update(team_number: team_number)
      else
        team << "#{j}.Гость @#{member.user.name}"
        member.update(team_number: team_number)
      end
    end
    members.pop(members_in_team)
    list << "Команда #{team_number}:\n#{team.join("\n")}"
  end

  def team_formation(members, list, team_number)
    team = []
    members.each do |member|
      if member.class == User
        team << ".@#{member.name}" if team_number == membership(member).team_number
      else
        team << ".Гость @#{member.user.name}" if team_number == member.team_number
      end
    end
    team.each.with_index(1) { |member, i| member.prepend(i.to_s) }
    list << "Команда #{team_number}:\n#{team.join("\n")}"
  end

  def membership(user)
    user.memberships.where(event: self).first
  end

  def close_time?
    starts_at_with_date <= Time.now
  end
end
