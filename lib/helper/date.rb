module Helper
  module Date
    DATE_FORMAT = /[0-3]{1}[0-9]{1}\.[0-1]{1}[0-9]{1}\.[1-2]{1}[0-9]{3}/

    def present_date?
      DateTime.parse(text) > DateTime.now
    end
  end
end
