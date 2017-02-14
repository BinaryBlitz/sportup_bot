require 'time'

module Helper
  module Validators
    include Date
    include Buttons

    MAX_TEXT_LENGTH = 100
    MAX_NUMBER_OF_MEMBERS = 1000
    MIN_NUMBER_OF_MEMBERS = 1

    def valid_date?(date)
      yield(date) if valid_date_format? && present_date?(date) && block_given?
    end

    def valid_time?(event, time)
      yield(time) if valid_time_format?(time) && present_time?(event, time) && block_given?
    end

    def valid_date_format?
      if (text =~ DATE_FORMAT).nil?
        send_message_with_reply("#{I18n.t('invalid_date')}")
        false
      else
        true
      end
    end

    def valid_length?(text)
      if text.length > MAX_TEXT_LENGTH
        send_message_with_reply("#{I18n.t('invalid_length')}")
      else
        block_given? && yield(text)
      end
    end

    def valid_number?(number)
      if number.to_i > MAX_NUMBER_OF_MEMBERS
        send_message_with_reply("#{I18n.t('max_number_of_members')}")
      elsif number.to_i < MIN_NUMBER_OF_MEMBERS
        send_message_with_reply("#{I18n.t('min_number_of_members')}")
      else
        block_given? && yield(number)
      end
    end

    def valid_number_of_teams?(number, event)
      if number.to_i > event.members_count
        send_message("#{I18n.t('max_number_of_teams')}")
      elsif number.to_i < MIN_NUMBER_OF_MEMBERS
        send_message("#{I18n.t('min_number_of_members')}")
      else
        block_given? && yield(number)
      end
    end

    def valid_vote?(number, event)
      if number.to_i > event.users.count
        send_message("#{I18n.t('max_number_of_teams')}")
      elsif number.to_i < MIN_NUMBER_OF_MEMBERS
        send_message("#{I18n.t('min_number_of_members')}")
      else
        block_given? && yield(number)
      end
    end

    def valid_time_format?(time)
      raise ArgumentError if Time.parse(time).to_date != ::Date.today
      true
    rescue
      send_message_with_reply("#{I18n.t('invalid_time')}")
      false
    end

    def valid_lang?(lang)
      unless AVAILABLE_LANGS.values.include?(lang)
        send_message("#{I18n.t('invalid_lang')}")
      end
      block_given? && yield(lang)
    end
  end
end
