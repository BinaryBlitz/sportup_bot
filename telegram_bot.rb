require_relative 'lib/bot_message_dispatcher'
require_relative 'lib/models/user'
require './environment'
require 'json'

class TelegramBot
  def call(env)
    @webhook_message = JSON.parse(env['rack.input'].read)
    BotMessageDispatcher.new(@webhook_message, user).process
    empty_response
  end

  def empty_response
    ['200', { 'Content-Type' => 'application/json' }, []]
  end

  def from
    if @webhook_message['callback_query'].nil?
      @webhook_message['message'].nil? ? @webhook_message['edited_message']['from'] : @webhook_message['message']['from']
    else
      @webhook_message['callback_query']['from']
    end
  end

  def user
    @user = User.find_by(telegram_id: from['id']) || register_user if from
  end

  def register_user
    @user = User.find_or_initialize_by(telegram_id: from['id'])
    @user.update_attributes!(
      first_name: from['first_name'],
      last_name: from['last_name'],
      username: from['username']
    )
    @user
  end
end
