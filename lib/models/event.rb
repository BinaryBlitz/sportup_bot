require 'active_record'
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
      Telegram::Bot::Api.new(Environment.token).send_message(
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

  def close_time?
    starts_at_with_date == current_time
  end

  def starts_at_with_date
    starts_at = I18n.l(self.starts_at, format: :short)
    I18n.l(add_time_to_date(starting_date, starts_at), format: :long)
  end
end
