require './lib/models/chat'

module BotCommand
  class Language < Base
    include Helper::Buttons
    include Helper::Validators

    def start
      send_message(
        'Выберите язык',
        reply_markup: keyboard_buttons(language_list),
        reply_to_message_id: @message['message']['message_id']
      )
      user.set_next_bot_command({ method: :set_lang, class: self.class.to_s })
    end

    def set_lang
      valid_lang?(text) do |lang|
        chat.update(language: AVAILABLE_LANGS.key(lang))
        send_message("Ваш язык выбран: #{AVAILABLE_LANGS[chat.language.to_sym]}")
        user.reset_next_bot_command
      end
    end
  end
end
