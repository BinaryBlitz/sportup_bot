module BotCommand
  class Unauthorized < Base
    def start
      send_message("#{I18n.t('not_admin')}")
    end
  end
end
