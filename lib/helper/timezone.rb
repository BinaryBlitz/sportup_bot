module Helper
  module Timezone
    def current_time_in_timezone
      timezone.time_with_offset(Time.now).utc
    end

    def current_date_in_timezone
      timezone.time_with_offset(Time.now).to_date
    end

    def local_to_utc(date)
      timezone.local_to_utc(date)
    end
  end
end
