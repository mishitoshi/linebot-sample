class LinebotController < ApplicationController
  require 'line/bot' # gem 'line-bot-api'

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_id = ENV['LINE_CHANNEL_ID']
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    error 400 do 'Bad Request' end unless client.validate_signature(body, signature)

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = if event.message['text'].include?('蒲生')
                      {
                        type: 'text',
                        text: 'よくぞ見破った！我が名はガモモンボールGT!!!!!'
                      }
                    else
                      {
                        type: 'text',
                        text: event.message['text'] + 'でやんす'
                      }
                    end
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open('content')
          tf.write(response.body)
        end
      end
    end
  end

  # Don't forget to return a successful response
  'OK'
end
