require_relative 'lib/bot_message_dispatcher'
require_relative 'lib/models/user'
require_relative 'router'
require_relative 'environment'
require 'json'

class TelegramBot
  def call(env)
    request = Rack::Request.new(env)
    if request.path_info == Environment.webhook_path
      return empty_response if env['rack.input'].read.empty?
      env['rack.input'].rewind
      webhook_message(env)
    else
      return Router.new(request).route
    end
  end

  def webhook_message(env)
    @webhook_message = JSON.parse(env['rack.input'].read)
    BotMessageDispatcher.new(@webhook_message, user).process
    empty_response
  end

  def empty_response
    ['200', { 'Content-Type' => 'application/json' }, []]
  end

  def from
    return if @webhook_message['edited_channel_post'] || @webhook_message.dig('channel_post', 'from')
    if @webhook_message['callback_query'].nil?
      @webhook_message.dig('message', 'from') || @webhook_message.dig('edited_message', 'from')
    else
      @webhook_message.dig('callback_query', 'from')
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
