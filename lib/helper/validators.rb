require 'time'

module Helper
  module Validators
    include Date
    include Buttons

    MAX_TEXT_LENGTH = 100
    MAX_NUMBER_OF_MEMBERS = 1000
    MIN_NUMBER_OF_MEMBERS = 1
    MAX_PRICE = 1_000_000
    MIN_PRICE = 0

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

    def valid_price?(price)
      if price.to_i > MAX_PRICE
        send_message_with_reply(I18n.t('max_price'))
        false
      elsif Integer(price) < MIN_PRICE
        send_message_with_reply(I18n.t('min_price'))
        false
      else
        block_given? && yield(price)
      end
      rescue
        send_message_with_reply(I18n.t('min_price'))
        false
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
      if AVAILABLE_LANGS.values.include?(lang)
        block_given? && yield(lang)
      else
        send_message(I18n.t('invalid_lang'))
        user.reset_next_bot_command
        false
      end
    end

    def valid_sport_type?(sport_type)
      if AVAILABLE_SPORT_TYPES.map { |st| I18n.t(st) }.include?(sport_type)
        block_given? && yield(sport_type)
      else
        send_message_with_reply(I18n.t('invalid_sport_type'))
        false
      end
    end

    def valid_team_limit?(team_limit)
      if TEAM_LIMIT.include?(team_limit)
        block_given? && yield(team_limit)
      else
        send_message_with_reply(I18n.t('invalid_team_limit'))
        false
      end
    end

    def valid_visibility?(visibility)
      if AVAILABLE_VISIBILITY.map { |visibility| I18n.t(visibility) }.include?(visibility)
        availability = AVAILABLE_VISIBILITY.detect { |availability| I18n.t(availability) == visibility }
        block_given? && yield(availability)
      else
        send_message_with_reply(I18n.t('invalid_visibility'))
        false
      end
    end
  end
end
