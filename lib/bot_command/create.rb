require './lib/models/event'
require './lib/models/app'
require './lib/models/app_event'
require './lib/models/app_user'
require './lib/models/app_sport_type'
require 'timezone'
require 'geocoder'

module BotCommand
  class Create < Base
    include Helper::Buttons
    include Helper::Validators

    def should_start?
      text == '/create' || text == "/create@#{bot_name}"
    end

    def start
      if event
        send_message(I18n.t('existing_event'))
      else
        send_message(
          I18n.t('sport_type'),
          reply_markup: keyboard_buttons(sport_types_list),
          reply_to_message_id: @message.dig('message', 'message_id')
        )
        user.next_bot_command(method: :sport_type, class: self.class.to_s)
      end
    end

    def sport_type
      valid_sport_type? text do |sport_type|
        event = Event.new(sport_type: sport_type, chat: chat)
        send_message_with_reply(I18n.t('name'))
        user.next_bot_command(method: :name, class: self.class.to_s, event: event)
      end
    end

    def name
      valid_length? text do |name|
        event = user.bot_command_data['event'].update(name: name)
        send_message_with_reply(I18n.t('address'))
        user.next_bot_command(method: :address, class: self.class.to_s, event: event)
      end
    end

    def address
      return send_message_with_reply(I18n.t('invalid_location')) unless location
      timezone
      address = Geocoder.address(coordinates, language: chat.language.to_sym)
      valid_length? address do |address|
        event = user.bot_command_data['event'].update(address: address)
        send_message_with_reply(I18n.t('starting_date'))
        user.next_bot_command(method: :starting_date, class: self.class.to_s, event: event)
      end
    end

    def starting_date
      valid_date?(event, text) do |date|
        event = user.bot_command_data['event'].update(starting_date: date)
        send_message_with_reply(I18n.t('starts_at'))
        user.next_bot_command(method: :starts_at, class: self.class.to_s, event: event)
      end
    end

    def starts_at
      valid_time?(event, text) do |starts_at|
        event = user.bot_command_data['event'].update(starts_at: starts_at)
        send_message_with_reply(I18n.t('ends_at'))
        user.next_bot_command(method: :ends_at, class: self.class.to_s, event: event)
      end
    end

    def ends_at
      valid_time?(event, text) do |ends_at|
        event = user.bot_command_data['event'].update(ends_at: ends_at)
        send_message_with_reply(I18n.t('user_limit'))
        user.next_bot_command(method: :user_limit, class: self.class.to_s, event: event)
      end
    end

    def user_limit
      valid_number? text do |user_limit|
        event = user.bot_command_data['event'].update(user_limit: user_limit)
        send_message(
          I18n.t('team_limit'),
          reply_markup: keyboard_buttons(team_limit_list),
          reply_to_message_id: @message.dig('message', 'message_id')
        )
        user.next_bot_command(method: :team_limit, class: self.class.to_s, event: event)
      end
    end

    def team_limit
      valid_team_limit? text do |team_limit|
        event = user.bot_command_data['event'].update(team_limit: team_limit)
        send_message_with_reply(I18n.t('price'))
        user.next_bot_command(method: :price, class: self.class.to_s, event: event)
      end
    end

    def price
      valid_price? text do |price|
        event = user.bot_command_data['event'].update(price: price)
        send_message(
          I18n.t('status'),
          reply_markup: keyboard_buttons(visibility_list),
          reply_to_message_id: @message.dig('message', 'message_id')
        )
        user.next_bot_command(method: :public, class: self.class.to_s, event: event)
      end
    end

    def public
      valid_visibility? text do |visibility|
        event = user.bot_command_data['event'].update(public: visibility)
        if visibility == 'public'
          create(event)
          send_message(info, reply_markup: { remove_keyboard: true }.to_json)
          user.reset_next_bot_command
        else
          send_message_with_reply(I18n.t('password'))
          user.next_bot_command(method: :password, class: self.class.to_s, event: event)
        end
      end
    end

    def password
      valid_length? text do |password|
        event = user.bot_command_data['event'].update(password: password)
        create(event)
        send_message(info, reply_markup: { remove_keyboard: true }.to_json)
        user.reset_next_bot_command
      end
    end

    def info
      "#{I18n.l(event.starting_date)} #{event.name} \n" \
      "#{event.address} \n" \
      "#{event.starts_at.strftime('%H:%M')} - #{event.ends_at.strftime('%H:%M')} \n" \
      "#{event.user_limit} #{I18n.t('participants')} \n" \
      "#{I18n.t('info_message')}"
    end

    def timezone
      timezone = Timezone.lookup(*coordinates)
      chat.update(timezone: timezone)
    end

    def create(event)
      telegram_event = Event.create(event)
      AppEvent.create(
        name: event['name'], address: event['address'],
        latitude: geocoder_coordinates(event)[0],
        longitude: geocoder_coordinates(event)[1],
        starts_at: telegram_event.date_with_time(telegram_event.starts_at),
        ends_at: event['ends_at'], price: event['price'], user_limit: event['user_limit'],
        team_limit: event['team_limit'], public: event['public'], password: event['password'],
        creator_id: app_user.id, sport_type_id: app_sport_type(event).id, chat_id: telegram_event.chat.chat_id
      )
    end

    def app_sport_type(event)
      # Remove sport type emoji and space
      sport_type = event['sport_type'][2..-1]
      AppSportType.find_by_name(sport_type)
    end

    def geocoder_coordinates(event)
      Geocoder.coordinates(event['address'])
    end
  end
end
