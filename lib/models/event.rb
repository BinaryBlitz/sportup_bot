require 'active_record'
require 'telegram/bot'
require './lib/helper'
require './environment'

class Event < ActiveRecord::Base
  include Helper::Date
  include Helper::Teams
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

  def starts_at_with_date
    starts_at = I18n.l(self.starts_at, format: :short)
    add_time_to_date(starting_date, starts_at)
  end

  def membership(user)
    user.memberships.where(event: self).first
  end

  private

  def close_time?
    starts_at_with_date <= Time.now
  end
end
