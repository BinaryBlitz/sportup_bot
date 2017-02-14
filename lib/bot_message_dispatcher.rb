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
    BotCommand::Help,
    BotCommand::Vote,
    BotCommand::BestPlayer
  ].freeze

  ADMIN_COMMANDS = [
    BotCommand::Create,
    BotCommand::Stop,
    BotCommand::Randomize
  ].freeze

  def initialize(message, user)
    @message = message
    @user = user
    @botan = Telegram::Bot::Botan::Api.new(Environment.botan_token)
  end

  def process
    return if @message['channel_post'] || @message['edited_channel_post']
    command = parse_command
    set_i18n if language
    return BotCommand::Language.new(@user, @message).start unless next_bot_command == 'set_lang' || language
    return BotCommand::Unauthorized.new(@user, @message).start unless admin?(command)
    if @message['edited_message']
      BotCommand::Base.new(@user, @message).repeat_command
    elsif @message['message']['text'].nil?
      BotCommand::Base.new(@user, @message).only_text
    elsif command
      @botan.track(command.to_s.gsub('BotCommand::', ''), @user.telegram_id, message: @message['message'])
      command = command.new(@user, @message)
      return command.send_message("#{I18n.t('no_events')}") unless event_exists?(command)
      command.start
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
    command.event || command.class == BotCommand::Create || command.class == BotCommand::Help
  end

  def admin?(command)
    return true unless ADMIN_COMMANDS.include?(command)
    BotCommand::Base.new(@user, @message).admin?
  end

  def language
    Chat.find_or_create_by(chat_id: @message['message']['chat']['id']).language
  end

  def set_i18n
    I18n.enforce_available_locales = false
    I18n.locale = language.to_sym
  end

  def next_bot_command
    @user.bot_command_data['method']
  end

  def execute_next_command_method(method)
    Object.const_get(@user.bot_command_data['class']).new(@user, @message).public_send(method)
  end
end
