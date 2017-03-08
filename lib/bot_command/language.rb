require './lib/models/chat'

module BotCommand
  class Language < Base
    include Helper::Buttons
    include Helper::Validators

    def start
      send_message(
        'Choose language',
        reply_markup: keyboard_buttons(language_list),
        reply_to_message_id: @message['message']['message_id']
      )
      user.set_next_bot_command({ method: :set_lang, class: self.class.to_s })
    end

    def set_lang
      valid_lang?(text, user) do |lang|
        chat.update(language: AVAILABLE_LANGS.key(lang))
        I18n.locale = chat.language.to_sym
        send_message(I18n.t('help_message'), reply_markup: { remove_keyboard: true }.to_json)
        user.reset_next_bot_command
      end
    end
  end
end
