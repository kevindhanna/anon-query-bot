$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'redis'
require 'slack-ruby-client'
require 'logger'
require 'config/configatron'
require 'app/slack_anon_query/bot'
require 'app/web/web'

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