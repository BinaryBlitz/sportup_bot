require 'telegram/bot'

module Helper
  module Buttons
    AVAILABLE_LANGS = {
      en: '🇬🇧 English',
      ru: '🇷🇺 Русский',
      de: '🇩🇪 Deutsch'
    }.freeze

    AVAILABLE_SPORT_TYPES = {
      I18n.t('hokey'),
      I18n.t('football'),
      I18n.t('basketball'),
      I18n.t('rugby'),
      I18n.t('tennis'),
      I18n.t('badminton'),
      I18n.t('baseball'),
      I18n.t('ping-pong')
    }.freeze

    def keyboard_buttons(button_list)
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: button_list,
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true
      )
    end

    def inline_buttons(button_list)
      { inline_keyboard: button_list }.to_json
    end

    def language_list
      AVAILABLE_LANGS.values.map do |lang|
        [{ text: lang }]
      end
    end

    def candidates_list(candidates)
      candidates.map do |candidate|
        [
          {
            text: candidate + " - #{votes_count(User.find_by_name(candidate))}",
            callback_data: candidate
          }
        ]
      end
    end

    def votes_count(user)
      event.membership(user).votes_count
    end
  end
end
