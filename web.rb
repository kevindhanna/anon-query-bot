require 'sinatra/base'

module SlackAnonQuery
    class Web < Sinatra::Base
        get '/' do
            "Anonymity is good for you"
        end
    end
end