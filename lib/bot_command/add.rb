require './lib/models/guest'

module BotCommand
  class Add < Base
    include Helper::Validators

    def should_start?
      text == '/add' || text == "/add@#{bot_name}" || command_with_params(text, '/add')
    end

    def start
      if event.started?
        send_message(I18n.t('started_event'))
      elsif event.members_count < event.user_limit
        add_guest
      else
        send_message(I18n.t('full_event'))
      end
      user.reset_next_bot_command
    end

    def add_guest
      if command_without_params?(text, '/add')
        add_anonymous_guest
      else
        add_guest_with_name
      end
      user.reset_next_bot_command
    end

    def add_anonymous_guest
      Guest.create(user: user, event: event)
      info_message(nil)
    end

    def add_guest_with_name
      name = text.gsub(/\/add\s+/, '')
      valid_length?(name) do |name|
        Guest.create(user: user, event: event, name: name)
        info_message(name)
      end
    end

    def info_message(name)
      send_message(
        "#{username} #{I18n.t('invited_guest', name: name)} " \
        "#{I18n.l(event.starting_date)} #{event.name} " \
        "#{I18n.t('participates')} #{event.members_count}/#{event.user_limit}" \
      )
    end
  end
end
