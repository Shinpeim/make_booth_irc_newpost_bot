# -*- coding: utf-8 -*-
require 'bundler'
Bundler.require
require 'json'

IRC_CHANNEL = '#makebooth'
IRC_NICK    = 'new_post_bot'
IRC_SERVER  = 'irc.freenode.net'

MB_HOST = 'makebooth.com'

EventMachine.run do
  uri = 'ws://ws.makebooth.com:5678/'

  ponder = Ponder::Thaum.new do |thaum|
    thaum.nick   = IRC_NICK
    thaum.server = IRC_SERVER
    thaum.port   = 6667
  end
  ponder.on :connect do
    ponder.join IRC_CHANNEL
  end
  ponder.connect

  con = EventMachine::WebSocketClient.connect(uri)
  con.disconnect do
    $stderr.puts 'disconnect'
    EventMachine.stop_event_loop
  end
  con.stream do |message|
    json = JSON.parse(message)
    $stdout.puts json.inspect
    next unless json['event'] == 2

    match = /href="(\/i\/[^"]+)"/.match(json['text'])
    link = 'http://' + MB_HOST + match[1];
    text = json['text'].gsub(/<\/?[^>]*>/, '') + ' ' + link

    ponder.message IRC_CHANNEL, text
  end
end
