module Helper
  module Date
    TIME_FORMAT = /\A[0-2]{1}[0-9]{1}:[0-5]{1}[0-9]{1}\z/
    MINUTES_IN_HOUR = 60
    SECONDS_IN_HOUR = 3600
    HOURS_IN_DAY = 24

    def present_date?(date)
      if ::Date.parse(format(date).to_s) >= ::Date.today
        true
      else
        send_message_with_reply("#{I18n.t('past_date')}")
        false
      end
    end

    def present_time?(event, time)
      date_time = add_time_to_date(event.starting_date, time)
      if event.starts_at && date_time > event.date_with_time(event.starts_at)
        true
      elsif !event.starts_at && date_time > Time.now
        true
      else
        send_message_with_reply("#{I18n.t('past_time')}")
        false
      end
    end

    def add_time_to_date(date, time)
      time = time.split(':').map(&:to_i)
      hours = time[0] * SECONDS_IN_HOUR
      minutes = time[1] * MINUTES_IN_HOUR
      return date + hours + minutes if minutes
      date + hours
    end

    def end_of_voting_time
      date_with_time(ends_at) + SECONDS_IN_HOUR*HOURS_IN_DAY
    end

    def remained_time
      (end_of_voting_time - Time.now).to_i / MINUTES_IN_HOUR
    end

    def format(date)
      ::Date.strptime(date, '%d.%m.%Y')
    end
  end
end
