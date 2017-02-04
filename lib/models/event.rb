require 'active_record'
require 'telegram/bot'
require './lib/helper'
require './environment'

class Event < ActiveRecord::Base
  include Helper::Date
  include Helper::Teams
  include Helper::Vote
  include Environment

  default_scope { where(closed: false) }

  has_many :users, through: :memberships
  has_many :memberships, dependent: :destroy
  has_many :guests, dependent: :destroy

  def api
    Telegram::Bot::Api.new(token)
  end

  def close
    if close_time?
      api.send_message(chat_id: chat_id, text: "#{I18n.t('farewell_message')}")
    end
  end

  def members_count
    users.count + guests.count
  end

  def members
    users + guests
  end

  def date_with_time(time)
    time = I18n.l(time, format: :short)
    add_time_to_date(starting_date, time)
  end

  def membership(user)
    user.memberships.where(event: self).first
  end

  def started?
    date_with_time(starts_at) <= Time.now
  end

  private

  def close_time?
    ((Time.now - date_with_time(starts_at)).to_i / 60).between?(0, 10)
  end
end
