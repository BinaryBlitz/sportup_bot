module Helper
  module Date
    DATE_FORMAT = /\A[0-3]{1}[0-9]{1}\.[0-1]{1}[0-9]{1}\.[1-2]{1}[0-9]{3}\z/

    def present_date?(date)
      if ::Date.parse(date) >= ::Date.today
        true
      else
        send_message_with_reply("#{I18n.t('past_date')}")
        false
      end
    end
  end
end
