require 'telegram/bot'
require './environment'

include Environment

module BotCommand
  class Base
    attr_reader :user, :message, :api

    def initialize(user = {}, message = {})
      @user = user
      @message = message
      @api = Telegram::Bot::Api.new(Environment.token)
    end

    def should_start?
      raise NotImplementedError, "Implementation of Base::should_start? method doesn't exist"
    end

    def start
      raise NotImplementedError, "Implementation of Base::start method doesn't exist"
    end

    def admin?
      return true if private_chat?
      admins = @api.getChatAdministrators(chat_id: chat_id)
      admin_ids = admins['result'].map { |user| user['user']['id'] }
      admin_ids.include?(@user.telegram_id.to_i) ? true : false
    rescue Telegram::Bot::Exceptions::ResponseError
      return
    end

    def only_text
      send_message_with_reply(I18n.t('empty_text')) if @message['message']['reply_to_message']
    end

    def repeat_command
      send_message(I18n.t('repeat_command'))
    end

    def event
      Event.find_by(chat: chat)
    end

    def chat
      Chat.find_or_create_by(chat_id: chat_id)
    end

    def send_message(text, options = {})
      @api.send_message({ chat_id: chat_id, text: text }.update(options))
    rescue Telegram::Bot::Exceptions::ResponseError
      return
    end

    protected

    def send_message_with_reply(text)
      @api.send_message(
        chat_id: chat_id,
        text: text,
        reply_to_message_id: @message['message']['message_id'],
        reply_markup: ::Telegram::Bot::Types::ForceReply.new(force_reply: true, selective: true)
      )
    end

    def text
      @message.dig('message', 'text')
    end

    def location
      @message.dig('message', 'location')
    end

    def coordinates
      [location['latitude'], location['longitude']]
    end

    def chat_id
      @message.dig('message', 'chat', 'id') || @message.dig('edited_message', 'chat', 'id')
    end

    def bot_name
      @api.getMe['result']['username']
    end

    def username
      @user.username.present? ? "@#{@user.name}" : @user.first_name.to_s
    end

    def private_chat?
      @message.dig('message', 'chat', 'type') == 'private'
    end

    def command_without_params?(text, command)
      text.split(command).empty? || text.split("#{command}@#{bot_name}").empty?
    end
  end
end
