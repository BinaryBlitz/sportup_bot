require_relative 'bot_command'
require 'geocoder'
require 'staccato'
require './environment'

class BotMessageDispatcher
  attr_reader :message, :user, :base

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
    BotCommand::Language,
    BotCommand::Description,
    BotCommand::ChangeStatus
  ].freeze

  ADMIN_COMMANDS = [
    BotCommand::Create,
    BotCommand::Stop,
    BotCommand::Randomize,
    BotCommand::Language,
    BotCommand::Description,
    BotCommand::ChangeStatus
  ].freeze

  EVENT_FREE_COMMANDS = [
    BotCommand::Start,
    BotCommand::Help,
    BotCommand::Create,
    BotCommand::Stop,
    BotCommand::Language
  ].freeze

  def initialize(message, user)
    @message = message
    @user = user
    @tracker = Staccato.tracker(Environment.tracker_id, user&.id)
    @base = BotCommand::Base.new(user, message)
  end

  def process
    set_i18n if language
    command = parse_command
    return command('Language').start if base.admin? && no_language?
    return command('Unauthorized').start unless command_for_admin?(command)
    return base.only_text if incorrect_message?
    return command('Undefined').start unless command || next_bot_command
    public_send("reply_to_#{message.keys[1]}".downcase.to_sym, command)
    user.save
  rescue
    return
  end

  def reply_to_message(command)
    if command && language
      command_process(command)
    elsif next_bot_command
      execute_next_command_method(next_bot_command)
    end
  end

  def reply_to_callback_query(_)
    command('Vote').vote if command('Vote').event
  end

  protected

  def parse_command
    AVAILABLE_COMMANDS.detect { |command_class| command_class.new(user, message).should_start? }
  end

  def event_exists?(command)
    command.event || EVENT_FREE_COMMANDS.include?(command.class)
  end

  def command_for_admin?(command)
    return true unless ADMIN_COMMANDS.include?(command)
    base.admin?
  end

  def no_language?
    return false if message['callback_query']
    language.nil? && next_bot_command != SET_LANG_COMMAND
  end

  def incorrect_message?
    [message.dig('message', 'text'), message.dig('message', 'location'), message['callback_query']].all?(&:nil?)
  end

  def command(command)
    Kernel.const_get("BotCommand::#{command}").new(user, message)
  end

  def command_process(command)
    command_class = command.new(user, message)
    return base.send_message(I18n.t('no_events')) unless event_exists?(command_class)
    track(command, command_class)
    command_class.start
  end

  def track(command, command_class)
    @tracker.pageview(
      path: command.to_s.gsub('BotCommand::', ''),
      geographical_id: country_code(command_class),
      user_language: language
    )
    @tracker.event(category: message['message']['chat']['type'], action: country_code(command_class))
  end

  def country_code(command)
    data = Geocoder.search(command.event&.address)[0]
    data.data['address_components'][5]['short_name'] if command.event && data.present?
  end

  def language
    Chat.find_or_create_by(chat_id: base.chat_id).language
  end

  def set_i18n
    I18n.enforce_available_locales = false
    I18n.locale = language.to_sym
  end

  def next_bot_command
    user.bot_command_data['method']
  end

  def execute_next_command_method(method)
    Kernel.const_get(user.bot_command_data['class']).new(user, message).public_send(method)
  end
end
