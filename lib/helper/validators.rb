require 'time'

module Helper
  module Validators
    include Date
    include Buttons

    MAX_TEXT_LENGTH = 100
    MAX_NUMBER_OF_MEMBERS = 1000
    MIN_NUMBER_OF_MEMBERS = 1

    def valid_date?(event, date)
      yield(date) if valid_date_format? && present_date?(new_event, date) && block_given?
    end

    def valid_time?(event, time)
      yield(time) if valid_time_format?(time) && present_time?(new_event, time) && block_given?
    end

    def new_event
      Event.new(user.bot_command_data['event'])
    end

    def valid_date_format?
      true if format(text)
    rescue
      send_message_with_reply(I18n.t('invalid_date'))
      false
    end

    def valid_length?(text)
      if text.length > MAX_TEXT_LENGTH
        send_message_with_reply(I18n.t('invalid_length'))
      else
        block_given? && yield(text)
      end
    end

    def valid_number?(number)
      if number.to_i > MAX_NUMBER_OF_MEMBERS
        send_message_with_reply(I18n.t('max_number_of_members'))
      elsif number.to_i < MIN_NUMBER_OF_MEMBERS
        send_message_with_reply(I18n.t('min_number_of_members'))
      else
        block_given? && yield(number)
      end
    end

    def valid_number_of_teams?(number, event)
      if number.to_i > event.members_count
        send_message(I18n.t('max_number_of_teams'))
      elsif number.to_i < MIN_NUMBER_OF_MEMBERS
        send_message(I18n.t('min_number_of_members'))
      else
        block_given? && yield(number)
      end
    end

    def valid_vote?(number, event)
      if number.to_i > event.users.count
        send_message(I18n.t('max_number_of_teams'))
      elsif number.to_i < MIN_NUMBER_OF_MEMBERS
        send_message(I18n.t('min_number_of_members'))
      else
        block_given? && yield(number)
      end
    end

    def valid_time_format?(time)
      raise ArgumentError if (time =~ TIME_FORMAT).nil? || Time.parse(time).to_date != ::Date.today
      true
    rescue
      send_message_with_reply(I18n.t('invalid_time'))
      false
    end

    def valid_lang?(lang, user)
      if AVAILABLE_LANGS.values.exclude?(lang)
        send_message(I18n.t('invalid_lang'))
        user.reset_next_bot_command
        false
      else
        block_given? && yield(lang)
      end
    end

    def valid_sport_type?(sport_type, user)
      if AVAILABLE_SPORT_TYPES.values.exclude?(sport_type)
        send_message(I18n.t('invalid_sport_type'))
        user.reset_next_bot_command
        false
      else
        block_given? && yield(sport_type)
      end
    end
  end
end
