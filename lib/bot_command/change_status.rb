module BotCommand
  class ChangeStatus < Base
    include Helper::Buttons
    include Helper::Validators

    def should_start?
      text == '/changestatus' || text == "/changestatus@#{bot_name}"
    end

    def start
      send_message(
        I18n.t('change_status'),
        reply_markup: keyboard_buttons(visibility_list),
        reply_to_message_id: @message.dig('message', 'message_id')
      )
      user.next_bot_command(method: :set_status, class: self.class.to_s)
    end

    def set_status
      valid_visibility? text do |visibility|
        event.update(public: visibility)
        if visibility == 'public'
          send_message(I18n.t('set_public'), reply_markup: { remove_keyboard: true }.to_json)
          user.reset_next_bot_command
        else
          send_message_with_reply(I18n.t('password'))
          user.next_bot_command(method: :password, class: self.class.to_s, event: event)
        end
      end
    end

    def password
      valid_length? text do |password|
        event.update(password: password)
        send_message(I18n.t('set_password'), reply_markup: { remove_keyboard: true }.to_json)
        user.reset_next_bot_command
      end
    end
  end
end
