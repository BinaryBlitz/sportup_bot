require './lib/models/guest'

module BotCommand
  class Delete < Base
    include Helper::Validators

    def should_start?
      text == '/delete' || text == "/delete@#{bot_name}" || command_with_params(text, '/delete')
    end

    def start
      if event.started?
        send_message(I18n.t('started_event'))
      elsif user.guests.where(event: event).any?
        delete_guest
      else
        send_message(I18n.t('no_guests'))
      end
      user.reset_next_bot_command
    end

    def delete_guest
      if command_without_params?(text, '/delete')
        delete_anonymous_guest
      else
        delete_guest_with_name
      end
      user.reset_next_bot_command
    end

    def delete_anonymous_guest
      user.guests.where(event: event).last.delete
      info_message
    end

    def delete_guest_with_name
      name = text.gsub(/\/delete\s+/, '')
      valid_length?(name) do |name|
        name.downcase!
        guest = user.guests.where(event: event).where("lower(name) = ?", name).last
        guest&.delete
        info_message(guest.name) if guest
      end
    end

    def info_message(name)
      send_message(
        "#{username} #{I18n.t('deleted_guest', name: name)} " \
        "#{I18n.l(event.starting_date)} #{event.name} " \
        "#{I18n.t('participates')} #{event.members_count}/#{event.user_limit}"
      )
    end
  end
end
