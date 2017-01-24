require 'rack'
require_relative 'telegram_bot'
require './app_configurator'

AppConfigurator.new.configure

run TelegramBot.new
