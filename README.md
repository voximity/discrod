# discrod

discrod is an experimental Discord library for Crystal. I am writing this to serve as a replacement
for one of my [bot projects'](https://engauge.zanderf.net/) current implementation in C#.

If you are looking for a production-ready Discord library, check out [discordcr](https://github.com/discordcr/discordcr).
This library is not ready for full use.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
    discrod:
        github: voximity/discrod
```

## Usage

```cr
require "discrod"

client = Discrod::Client.new token: "my-token", token_type: Discrod::TokenType::Bot

client.on_message_create do |message|
    if message.content == "ping"
        message.react Discrod::Emoji.new ":confetti_ball:"
        message.channel.create_message embed: Discrod::EmbedBuilder.new { |e| e.with_title "Pong!"; e.with_description "discrod speaking here!" }.build
    end
end

client.connect
```

## Contributing

1. Fork it (https://github.com/voximity/discrod/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
