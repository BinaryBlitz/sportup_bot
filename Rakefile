require 'rubygems'
require 'bundler/setup'
require 'pg'
require 'active_record'
require 'yaml'
require './lib/models/event'
require './lib/models/membership'
require './lib/models/user'
require './lib/models/chat'
require './app_configurator'

namespace :db do
  desc 'Migrate the database'
  task :migrate do
    connection_details = YAML.load(File.open('config/database.yml'))[(ENV['BOT_ENV'] || 'development')]
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || connection_details)
    ActiveRecord::Migrator.migrate('db/migrate/')
  end

  desc 'Create the database'
  task :create do
    connection_details = YAML.load(File.read('config/database.yml'))[(ENV['BOT_ENV'] || 'development')]
    admin_connection = connection_details.merge('database' => 'postgres', 'schema_search_path' => 'public')
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || admin_connection)
    ActiveRecord::Base.connection.create_database(connection_details.fetch('database'))
  end

  desc 'Drop the database'
  task :drop do
    connection_details = YAML.load(File.open('config/database.yml'))[(ENV['BOT_ENV'] || 'development')]
    admin_connection = connection_details.merge('database' => 'postgres',
                                                'schema_search_path' => 'public')
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || admin_connection)
    ActiveRecord::Base.connection.drop_database(connection_details.fetch('database'))
  end

  desc 'Setup the database'
  task :setup do
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end
end

desc 'Start event'
task :start_event do
  AppConfigurator.new.configure
  Event.all.each(&:start_event) if Event.any?
end

desc 'Start vote'
task :start_vote do
  AppConfigurator.new.configure
  Event.all.each(&:begin_vote) if Event.any?
end

desc 'Close vote'
task :close_vote do
  AppConfigurator.new.configure
  Event.all.each(&:close_vote_on_time) if Event.any?
end
