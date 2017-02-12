require './lib/models/event'
require 'telegram/bot'

module BotCommand
  class Create < Base
    include Helper::Validators

    def should_start?
      text == '/create' || text == "/create@#{bot_name}"
    end

    def start
      if event
        send_message("#{I18n.t('existing_event')}")
      else
        send_message_with_reply("#{I18n.t('name')}")
        user.set_next_bot_command({ method: :name , class: self.class.to_s })
      end
    end

    def name
      valid_length? text do |name|
        event = Event.new(name: name, chat_id: chat_id)
        send_message_with_reply("#{I18n.t('address')}")
        user.set_next_bot_command({ method: :address , class: self.class.to_s, event: event })
      end
    end

    def address
      valid_length? text do |address|
        event = user.bot_command_data['event'].update(address: address)
        send_message_with_reply("#{I18n.t('starting_date')}")
        user.set_next_bot_command({ method: :starting_date , class: self.class.to_s, event: event })
      end
    end

    def starting_date
      valid_date? text do |date|
        event = user.bot_command_data['event'].update(starting_date: date)
        send_message_with_reply("#{I18n.t('starts_at')}")
        user.set_next_bot_command({ method: :starts_at , class: self.class.to_s, event: event })
      end
    end

    def starts_at
      event = Event.new(user.bot_command_data['event'])
      valid_time?(event, text) do |starts_at|
        event.starts_at = starts_at
        send_message_with_reply("#{I18n.t('ends_at')}")
        user.set_next_bot_command({ method: :ends_at , class: self.class.to_s, event: event })
      end
    end

    def ends_at
      event = Event.new(user.bot_command_data['event'])
      valid_time?(event, text) do |ends_at|
        event.ends_at = ends_at
        send_message_with_reply("#{I18n.t('user_limit')}")
        user.set_next_bot_command({ method: :user_limit , class: self.class.to_s, event: event })
      end
    end

    def user_limit
      valid_number? text do |user_limit|
        event = user.bot_command_data['event'].update(user_limit: user_limit)
        Event.create(event)
        send_message(info)
        user.reset_next_bot_command
      end
    end

    def info
      "#{I18n.l(event.starting_date)} #{event.name} \n" \
      "#{event.address} \n" \
      "#{event.starts_at.strftime("%H:%M")} - #{event.ends_at.strftime("%H:%M")} \n" \
      "#{event.user_limit} участников \n" \
      "#{I18n.t('info_message')}"
    end
  end
end
