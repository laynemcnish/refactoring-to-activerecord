require_relative "./../app"
require "user"
require "fish"
require "connection"
require "capybara/rspec"
require "database_cleaner"
ENV["RACK_ENV"] = "test"

Capybara.app = App

RSpec.configure do |config|

  config.before(:suite) do
    GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
