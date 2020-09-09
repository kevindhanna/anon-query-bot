class Bot
  DM_CHANNEL_PREFIX = 'D'
  DM_RESPONSE = configatron.bot.dm_response
  PUBLIC_CHANNEL_NAME = configatron.bot.channel_name
  ERROR_RESPONSE = configatron.bot.error_response
  puts PUBLIC_CHANNEL_NAME
  @instance = nil

  def self.instance
    @instance
  end

  def self.create(client, storage, log)
    raise 'bot already instantiated' if @instance&.client_started?

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

    sleep 1 until client.started? || !thread.alive?

    @instance.store_channel_id unless !thread.alive?
  end

  def initialize(client, storage, log)
    @client = client
    @storage = storage
    @log = log
  end

  def process_message(data)
    return unless data.channel && data.channel[0] == DM_CHANNEL_PREFIX

    @log.dm_received
    begin
      last_message = @storage.last_message
      if valid_message?(data.text, last_message)
        handle_message(data.text, data.channel)
      else
        @log.invalid_message(data.text, last_message)
      end
    rescue StandardError => e
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
    @storage.last_message = message
    @log.reply_to_user
    @client.message(channel: dm_channel, text: DM_RESPONSE)
  end
end

class Storage
  @instance = nil

  def self.instance
    @instance
  end

  def self.create
    @instance = Storage.new(configatron.redis.url) unless @instance
    @instance
  end

  def initialize(url)
    @store = Redis.new(url: url)
  end

  def last_message
    @store.get('lm')
  end

  def last_message=(message)
    @store.set('lm', message)
    @store.expire('lm', 30)
  end

  def token=(token)
    @store.set('token', token)
  end

  def token
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
    @stdout.info('channel id') { "public message output channel: #{channel}" }
    @file_out.info('channel id') { "public message output channel: #{channel}" }
  end

  def dm_received
    @stdout.info('DM recieved')
    @file_out.info('DM recieved')
  end

  def posting_to_channel(message)
    @stdout.info('post message') { "Posting message to public channel: '#{message}'" }
    @file_out.info('post message') { "Posting message public channel: '#{message}'" }
  end

  def reply_to_user
    @stdout.info('replying to user')
    @file_out.info('replying to user')
  end

  def invalid_message(message, last_message)
    @stdout.info("invalid message: '#{message}' - last message: '#{last_message}'")
    @file_out.info("invalid message: '#{message} - last message: '#{last_message}'")
  end

  def getting_token
    @stdout.info('requesting oAuth token')
    @file_out.info('requesting oAuth token')
  end

  def using_stored_token
    @stdout.info('Using stored oAuth token')
    @file_out.info('Using stored oAuth token')
  end

  def success
    @stdout.info('Success.')
    @file_out.info('Success.')
  end

  def something_went_wrong(error)
    @stdout.fatal('ERROR') { error.message }
    @stdout.warn('TRACE:') { error.backtrace }
    @file_out.fatal('ERROR') { error.message }
    @file_out.warn('TRACE:') { error.backtrace }
  end
end
