module BotCommand
  class Description < Base
    include Helper::Buttons
    include Helper::Validators

    def should_start?
      text == '/description' || text == "/description@#{bot_name}"
    end

    def start
      send_message_with_reply(I18n.t('description'))
      user.next_bot_command(method: :description, class: self.class.to_s)
    end

    def description
      event.update(description: text)
      send_message(I18n.t('set_description'))
      user.reset_next_bot_command
    end
  end
end
