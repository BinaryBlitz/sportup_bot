require 'active_record'
require './lib/helper'
require './lib/bot_command/base'

class Event < ActiveRecord::Base
  include Helper::Timezone
  include Helper::Date
  include Helper::Teams
  include Helper::Vote

  default_scope { where(closed: false) }

  FREQUENCY_IN_MINUTES = 10
  SECONDS_IN_MINUTE = 60

  belongs_to :chat

  has_many :users, through: :memberships
  has_many :memberships, dependent: :destroy
  has_many :guests, dependent: :destroy

  def start_event
    return unless job_time?(date_with_time(starts_at))
    I18n.locale = lang if lang
    BotCommand::Base.new.send_message(I18n.t('farewell_message'), chat_id: chat.chat_id)
  end

  def members_count
    users.count + guests.count
  end

  def members
    users + guests
  end

  def date_with_time(time)
    time = I18n.l(time, format: :short)
    date = add_time_to_date(starting_date, time)
    local_to_utc(date)
  end

  def membership(user)
    user.memberships.where(event: self).first
  end

  def started?
    date_with_time(starts_at) <= current_time_in_timezone
  end

  def lang
    chat.language.to_sym if chat&.language
  end

  def timezone
    Timezone.fetch(chat.timezone, Timezone['Europe/Moscow'])
  end

  def job_time?(time)
    ((current_time_in_timezone - time).to_i / SECONDS_IN_MINUTE).between?(0, FREQUENCY_IN_MINUTES)
  end
end
