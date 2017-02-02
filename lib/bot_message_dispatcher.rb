require_relative 'bot_command'
require 'telegram/bot/botan'
require './environment'

class BotMessageDispatcher
  attr_reader :message, :user

  AVAILABLE_COMMANDS = [
    BotCommand::Start,
    BotCommand::Stop,
    BotCommand::Create,
    BotCommand::In,
    BotCommand::Out,
    BotCommand::Add,
    BotCommand::Delete,
    BotCommand::List,
    BotCommand::Randomize,
    BotCommand::Teams,
    BotCommand::Help
  ].freeze

  def initialize(message, user)
    @message = message
    @user = user
    @botan = Telegram::Bot::Botan::Api.new(Environment.botan_token)
  end

  def process
    command = parse_command
    if @message['message'].nil? || @message['message']['text'].nil?
      BotCommand::Base.new(@user, @message).only_text
    elsif command_not_from_admin?(command)
      BotCommand::Unauthorized.new(@user, @message).start
    elsif command
      command = command.new(@user, @message)
      return command.send_message("#{I18n.t('no_events')}") unless event_exists?(command)
      command.start
      @botan.track(@message['message']['text'], @message['message']['from']['id'])
    elsif next_bot_command
      execute_next_command_method(next_bot_command)
    else
      BotCommand::Undefined.new(@user, @message).start
    end && user.save
  end

  protected

  def parse_command
    AVAILABLE_COMMANDS.detect { |command_class| command_class.new(@user, @message).should_start? }
  end

  def event_exists?(command)
    command.event || command.class == BotCommand::Create
  end

  def commands_for_admin?(command)
    command == BotCommand::Create || command == BotCommand::Stop || command == BotCommand::Randomize
  end

  def command_not_from_admin?(command)
    commands_for_admin?(command) && !BotCommand::Base.new(@user, @message).admin?
  end

  def next_bot_command
    @user.bot_command_data['method']
  end

  def execute_next_command_method(method)
    Object.const_get(@user.bot_command_data['class']).new(@user, @message).public_send(method)
  end
end
