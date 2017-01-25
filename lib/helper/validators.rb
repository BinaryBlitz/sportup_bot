require 'time'

module Helper
  module Validators
    include Date

    MAX_TEXT_LENGTH = 100
    MAX_NUMBER_OF_MEMBERS = 1000
    MIN_NUMBER_OF_MEMBERS = 1

    def valid_date?(date)
      yield(date) if valid_date_format? && present_date?(date) && block_given?
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

    def valid_time?(time)
      Time.parse(time)
      block_given? && yield(time)
    rescue
      send_message_with_reply("#{I18n.t('invalid_time')}")
    end
  end
end
