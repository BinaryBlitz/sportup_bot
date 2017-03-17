require 'telegram/bot'

module Helper
  module Buttons
    AVAILABLE_LANGS = {
      en: '🇬🇧 English',
      ru: '🇷🇺 Русский',
      de: '🇩🇪 Deutsch'
    }.freeze

    def keyboard_buttons(button_list)
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: button_list,
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true
      )
    end

    def language_list
      AVAILABLE_LANGS.values.map do |lang|
        [] << { text: lang }
      end
    end
  end
end
