require 'active_record'
require './lib/helper'
require './lib/bot_command/base'

class Event < ActiveRecord::Base
  include Helper::Date
  include Helper::Teams
  include Helper::Vote

  default_scope { where(closed: false) }

  belongs_to :chat

  has_many :users, through: :memberships
  has_many :memberships, dependent: :destroy
  has_many :guests, dependent: :destroy

  def close
    return unless close_time?
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
    add_time_to_date(starting_date, time)
  end

  def membership(user)
    user.memberships.where(event: self).first
  end

  def started?
    date_with_time(starts_at) <= Time.now
  end

  def lang
    chat.language.to_sym if chat&.language
  end

  private

  def close_time?
    ((Time.now - date_with_time(starts_at)).to_i / 60).between?(0, 10)
  end
end
