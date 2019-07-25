$LOAD_PATH.unshift(File.dirname(__FILE__))

unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'
  Dotenv.load
end

require 'redis'
require 'slack-ruby-client'
require 'app/slack_anon_query/bot'
require 'app/web/web'
require 'logger'

$stdout.sync = true

Thread.abort_on_exception = true

Thread.new do
  begin
    $bot.start!
  rescue Exception => e
    STDERR.puts "ERROR: #{e}"
    STDERR.puts e.backtrace
    raise e
  end
end

run SlackAnonQuery::Web