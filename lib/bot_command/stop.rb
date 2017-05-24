module BotCommand
  class Stop < Base
    def should_start?
      text == '/stop' || text == "/stop@#{bot_name}"
    end

    def start
      send_message(I18n.t('event_cancellation'))
      AppEvent.find_by(chat_id: event.chat.chat_id)&.destroy
      event&.destroy
      user.reset_next_bot_command
    end
  end
end
