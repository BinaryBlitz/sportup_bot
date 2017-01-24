require 'telegram/bot'
require './environment'

include Environment

module BotCommand
  class Base
    attr_reader :user, :message, :api

    def initialize(user, message)
      @user = user
      @message = message
      @api = Telegram::Bot::Api.new(Environment.token)
    end

    def should_start?
      fail NotImplementedError, 'Implementation of Base::should_start? method doesn\'t exist'
    end

    def start
      fail NotImplementedError, 'Implementation of Base::start method doesn\'t exist'
    end

    def admin?
      return true if private_chat?
      admins = @api.getChatAdministrators(chat_id: chat_id)
      admin_ids = admins['result'].map { |user| user['user']['id'] }
      admin_ids.include?(@user.telegram_id.to_i) ? true : false
    end

    protected

    def send_message(text, options = {})
      @api.send_message({ chat_id: chat_id, text: text }.update(options))
    end

    def send_message_with_reply(text)
      @api.send_message({
        chat_id: chat_id,
        text: text,
        reply_to_message_id: @message['message']['message_id'],
        reply_markup: ::Telegram::Bot::Types::ForceReply.new(force_reply: true, selective: true)
      })
    end

    def text
      @message['message']['text'] unless @message['message'].nil?
    end

    def chat_id
      @message['message']['chat']['id']
    end

    def event
      Event.find_by(chat_id: chat_id)
    end

    def bot_name
      @api.getMe['result']['username']
    end

    def private_chat?
      @message['message']['chat']['type'] == 'private'
    end
  end
end
