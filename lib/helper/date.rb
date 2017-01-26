require 'time'

module Helper
  module Date
    DATE_FORMAT = /\A[0-3]{1}[0-9]{1}\.[0-1]{1}[0-9]{1}\.[1-2]{1}[0-9]{3}\z/
    MINUTES_IN_HOUR = 60

    def present_date?(date)
      if ::Date.parse(date) >= ::Date.today
        true
      else
        send_message_with_reply("#{I18n.t('past_date')}")
        false
      end
    end

    def present_time?(event, time)
      date_with_time = I18n.l(add_time_to_date(event.starting_date, time), format: :long)
      if event.starts_at && date_with_time > event.starts_at_with_date
        true
      elsif !event.starts_at && date_with_time > current_time
        true
      else
        send_message_with_reply("#{I18n.t('past_time')}")
        false
      end
    end

    def add_time_to_date(date, time)
      time = time.split(':').map(&:to_i)
      date + time[0]*MINUTES_IN_HOUR*MINUTES_IN_HOUR + time[1]*MINUTES_IN_HOUR
    end

    def current_time
      I18n.l(Time.now, format: :long)
    end
  end
end
