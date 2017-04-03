require_relative 'bot_command'
require 'geocoder'
require 'staccato'
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
    BotCommand::Language
  ].freeze

  ADMIN_COMMANDS = [
    BotCommand::Create,
    BotCommand::Stop,
    BotCommand::Randomize,
    BotCommand::Language
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
    @tracker = Staccato.tracker(Environment.tracker_id, user.id)
  end

  def process
    set_i18n if language
    command = parse_command
    return start_command('Language') if base_command.admin? && no_language?
    return start_command('Unauthorized') unless command_for_admin?(command)
    if @message['edited_message']
      base_command.repeat_command
    elsif @message['callback_query'] && vote_command.event
     vote_command.vote
    elsif incorrect_message?
      base_command.only_text
    elsif @message['message']
      message_process(command)
    else
      start_command('Undefined')
    end && user.save
  rescue
    return
  end

  protected

  def parse_command
    AVAILABLE_COMMANDS.detect { |command_class| command_class.new(@user, @message).should_start? }
  end

  def event_exists?(command)
    command.event || EVENT_FREE_COMMANDS.include?(command.class)
  end

  def command_for_admin?(command)
    return true unless ADMIN_COMMANDS.include?(command)
    base_command.admin?
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
    command_class = command.new(@user, @message)
    return command_class.send_message(I18n.t('no_events')) unless event_exists?(command_class)
    track(command, command_class)
    command_class.start
  end

  def message_process(command)
    if command && language
      command_process(command)
    elsif next_bot_command
      execute_next_command_method(next_bot_command)
    end
  end

  def track(command, command_class)
    @tracker.pageview(
      path: command.to_s.gsub('BotCommand::', ''),
      geographical_id: country_code(command_class)
    )
    @tracker.event(category: @message['message']['chat']['type'], action: base_command.event)
  end

  def country_code(command)
    data = Geocoder.search(command.event&.address)[0]
    data.data['address_components'][5]['short_name'] if command.event && data.present?
  end

  def language
    Chat.find_or_create_by(chat_id: base_command.chat_id).language
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
