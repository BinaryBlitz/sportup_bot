require_relative 'bot_command'
require 'telegram/bot/botan'
require './environment'

class BotMessageDispatcher
  attr_reader :message, :user

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
    BotCommand::Create
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
    return BotCommand::Language.new(@user, @message).start if admin? && has_no_language?
    return BotCommand::Unauthorized.new(@user, @message).start unless command_for_admin?(command)
    if @message['edited_message']
      BotCommand::Base.new(@user, @message).repeat_command
    elsif @message['message']['text'].nil?
      BotCommand::Base.new(@user, @message).only_text
    elsif command
      command_process(command)
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
    command.event || ALLOWED_COMMANDS.include?(command.class)
  end

  def admin?
    BotCommand::Base.new(@user, @message).admin?
  end

  def command_for_admin?(command)
    return true unless ADMIN_COMMANDS.include?(command)
    admin?
  end

  def has_no_language?
    language.nil? && next_bot_command != 'set_lang'
  end

  def command_process(command)
    @botan.track(command.to_s.gsub('BotCommand::', ''), @user.telegram_id, message: @message['message'])
    command = command.new(@user, @message)
    return command.send_message("#{I18n.t('no_events')}") unless event_exists?(command)
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
