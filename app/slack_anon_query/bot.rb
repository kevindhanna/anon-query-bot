class Bot
  DM_CHANNEL_ID = "D"
  DM_RESPONSE = ENV['DM_RESPONSE'] || "Thanks, I’ve submitted your question."
  PUBLIC_CHANNEL_NAME = ENV['CHANNEL_NAME']
  ERROR_RESPONSE = ENV['ERROR_RESPONSE'] || "Sorry, something went wrong, please contact your administrator."

  @instance = nil

  def self.instance
    @instance
  end

  def self.create(client, storage, log)
    raise 'bot already instantiated' if @instance && @instance.client_started?

    @instance = Bot.new(client, storage, log)

    client.on :message do |data|
      @instance.process_message(data)
    end

    Thread.abort_on_exception = true

    thread = Thread.new do
      begin
        client.start!
      rescue StandardError => e
        log.something_went_wrong(e)
      end
    end

    until client.started? || !thread.alive?
      sleep 1
    end
    @instance.store_channel_id unless !thread.alive?
  end

  def initialize(client, storage, log)
    @client = client
    @storage = storage
    @log = log
  end

  def process_message(data)
    return unless data.channel && data.channel[0] == DM_CHANNEL_ID

    @log.dm_received(data.channel)
    begin
      last_message = @storage.get_last_message
      if valid_message?(data.text, last_message)
        handle_message(data.text, data.channel)
      else
        @log.invalid_message(data.text, last_message)
      end
    rescue StandardError => e
      puts e.message
      @log.something_went_wrong(e)
      @client.message(channel: data.channel, text: ERROR_RESPONSE)
    end
  end

  def store_channel_id
    channel = @client.channels.values.detect do |ch|
      ch.name == PUBLIC_CHANNEL_NAME
    end

    @channel_id = channel.id

    @log.output_channel(@channel_id)
  end

  def client_started?
    @client.started?
  end

  private

  def valid_message?(message, last_message)
    message != last_message &&
      message != DM_RESPONSE &&
      message != ERROR_RESPONSE &&
      message.length > 1
  end

  def handle_message(message, dm_channel)
    @log.posting_to_channel(message)
    @client.message(channel: @channel_id, text: message)
    @storage.set_last_message(message)
    @log.informing_user
    @client.message(channel: dm_channel, text: DM_RESPONSE)
  end
end

class Storage
  @instance = nil

  def self.instance
    @instance
  end

  def self.create
    @instance = Storage.new(ENV['REDIS_URL']) unless @instance
    @instance
  end

  def initialize(url)
    @store = Redis.new(url: url)
  end

  def get_last_message
    @store.get('lm')
  end

  def set_last_message(message)
    @store.set('lm', message)
    @store.expire('lm', 30)
  end

  def set_token(token)
    @store.set('token', token)
  end

  def get_token
    @store.get('token')
  end
end

class Log
  @instance = nil

  def self.instance
    @instance
  end
  
  def self.create
    return @instance if @instance

    @instance = Log.new
    @instance
  end

  def initialize
    @stdout = Logger.new(STDOUT)
    @file_out = Logger.new('slack_bot.log', 10, 1_024_000)
  end

  def output_channel(channel)
    @stdout.info ('channel id') {"message output channel: #{channel}"}
    @file_out.info ('channel id') {"message output channel: #{channel}"}
  end

  def dm_received(channel)
    @stdout.info ('DM recieved') { "DM recieved. Channel id: #{channel}" }
    @file_out.info ('DM recieved') { "DM recieved. Channel id: #{channel}" }
  end
  
  def posting_to_channel(message)
    @stdout.info ('post message') { "Posting message to public channel: '#{message}'" }
    @file_out.info ('post message') { "Posting message public channel: '#{message}'" }
  end

  def informing_user
    @stdout.info ('inform user')
    @file_out.info ('inform user')
  end

  def invalid_message(message, last_message)
    @stdout.info ("invalid message: '#{message}' - last message: '#{last_message}'")
    @file_out.info ("invalid message: '#{message} - last message: '#{last_message}'")
  end

  def getting_token
    @stdout.info("requesting oAuth token")
    @file_out.info("requesting oAuth token")
  end

  def using_stored_token
    @stdout.info("Using stored oAuth token")
    @file_out.info("Using stored oAuth token")
  end

  def success
    @stdout.info("Success.")
    @file_out.info("Success.")
  end

  def something_went_wrong(error)
    @stdout.fatal('ERROR') { "#{error.message}" }
    @stdout.warn('TRACE:') { "#{error.backtrace}" }
    @file_out.fatal('ERROR') { "#{error.message}" }
    @file_out.warn('TRACE:') { "#{error.backtrace}" }
  end
end
