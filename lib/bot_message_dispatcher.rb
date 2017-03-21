require_relative 'bot_command'
require 'telegram/bot/botan'
require './environment'

class BotMessageDispatcher
  attr_reader :message, :user

  SET_LANG_COMMAND = 'set_lang'.freeze
  AVAILABLE_COMMANDS = [
    BotCommand::Help,
    BotCommand::Create,
    BotCommand::Stop,
    BotCommand::Start,
    BotCommand::List,
    BotCommand::In,
    BotCommand::Out,
    BotCommand::Add,
    BotCommand::Delete,
    BotCommand::Randomize,
    BotCommand::Teams,
    BotCommand::Vote,
    BotCommand::BestPlayer
  ].freeze

  ADMIN_COMMANDS = [
    BotCommand::Create,
    BotCommand::Stop,
    BotCommand::Randomize
  ].freeze

  ALLOWED_COMMANDS = [
    BotCommand::Start,
    BotCommand::Help,
    BotCommand::Create,
    BotCommand::Stop
  ].freeze

  def initialize(message, user)
    @message = message
    @user = user
    @botan = Telegram::Bot::Botan::Api.new(Environment.botan_token)
  end

  def process
    return if @message['channel_post'] || @message['edited_channel_post']
    set_i18n if language
    command = parse_command
    return start_command('Language') if admin? && no_language?
    return start_command('Unauthorized') unless command_for_admin?(command)
    if @message['edited_message']
      base_command.repeat_command
    elsif @message['callback_query'] && vote_command.event
     vote_command.vote
    elsif incorrect_message?
      base_command.only_text
    elsif command && language
      command_process(command)
    elsif next_bot_command
      execute_next_command_method(next_bot_command)
    else
      start_command('Undefined')
    end && user.save
  end

  protected

  def parse_command
    AVAILABLE_COMMANDS.detect { |command_class| command_class.new(@user, @message).should_start? }
  end

  def event_exists?(command)
    command.event || ALLOWED_COMMANDS.include?(command.class)
  end

  def admin?
    BotCommand::Base.new(@user, @message).admin?
  end

  def command_for_admin?(command)
    return true unless ADMIN_COMMANDS.include?(command)
    admin?
  end

  def no_language?
    return false if @message['callback_query']
    language.nil? && next_bot_command != SET_LANG_COMMAND
  end

  def incorrect_message?
    @message.dig('message', 'text').nil? && @message.dig('message', 'location').nil? && @message['callback_query'].nil?
  end

  def start_command(command)
    BotCommand::const_get(command).new(@user, @message).start
  end

  def vote_command
    BotCommand::Vote.new(@user, @message)
  end

  def base_command
    BotCommand::Base.new(@user, @message)
  end

  def command_process(command)
    @botan.track(command.to_s.gsub('BotCommand::', ''), @user.telegram_id, message: @message['message'])
    command = command.new(@user, @message)
    return command.send_message(I18n.t('no_events')) unless event_exists?(command)
    command.start
  end

  def language
    Chat.find_or_create_by(chat_id: chat_id).language
  end

  def chat_id
    @message&.dig('message', 'chat', 'id') || @message&.dig('edited_message', 'chat', 'id')
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
