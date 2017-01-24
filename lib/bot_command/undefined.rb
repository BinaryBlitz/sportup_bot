module BotCommand
  class Undefined < Base
    def start
      send_message("#{I18n.t('undefined_message')}")
    end
  end
end
