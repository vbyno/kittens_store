# frozen_string_literal: true

require 'database_cleaner'

RSpec.configure do |config|
  config.around do |example|
    DatabaseCleaner.allow_remote_database_url = true
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
