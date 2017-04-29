require 'telegram/bot'
require 'i18n'

I18n.enforce_available_locales = false

module Helper
  module Buttons
    AVAILABLE_LANGS = {
      en: '🇬🇧 English',
      ru: '🇷🇺 Русский',
      de: '🇩🇪 Deutsch'
    }.freeze

    AVAILABLE_SPORT_TYPES = [
      'hokey', 'football', 'basketball', 'rugby',
      'tennis', 'badminton', 'baseball', 'ping-pong'
    ].freeze

    TEAM_LIMIT = *(1..6).map(&:to_s).freeze

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

    def sport_types_list
      AVAILABLE_SPORT_TYPES.map do |sport_type|
        { text: I18n.t("#{sport_type}") }
      end.each_slice(2).map { |e| e }
    end

    def team_limit_list
      TEAM_LIMIT.map { |number| [{ text: number }] }.each_slice(2).map { |e| e }
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
