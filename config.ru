$LOAD_PATH.unshift(File.dirname(__FILE__))

unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'
  Dotenv.load
end

require 'slack-ruby-bot'
require 'app/slack-anon-query/bot'
require 'app/web/web'


Thread.abort_on_exception = true

Thread.new do
  begin
    SlackAnonQuery::Bot.run
  rescue Exception => e
    STDERR.puts "ERROR: #{e}"
    STDERR.puts e.backtrace
    raise e
  end
end

run SlackAnonQuery::Web