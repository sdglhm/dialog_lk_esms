# DialogLkEsms

A Ruby gem for sending SMS messages via Dialog eSMS API in Sri Lanka. Built with dry-rb ecosystem for robust, functional programming patterns.

## Features

- 🚀 **Simple API** - Easy to use client for sending SMS messages
- 💰 **Balance Checking** - Check your account balance
- 🔒 **Type Safety** - Built with dry-types for data validation
- ⚡ **Functional Programming** - Uses dry-monads for reliable error handling
- 🛡️ **Robust Error Handling** - Comprehensive error types and handling
- 🔧 **Configurable** - Flexible configuration options

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dialog_lk_esms'
```

And then execute:

```bash
$ bundle install
```

Or install it directly:

```bash
$ gem install dialog_lk_esms
```

## Quick Start

### Basic Usage

```ruby
require 'dialog_lk_esms'

# Create a client
client = DialogLkEsms.client(api_key: 'your_api_key_here')

# Send a message
result = client.send_message(
  number_list: '0771234567',
  message: 'Hello from Dialog eSMS!',
  source_address: 'YOUR_SENDER_ID'
)

if result.success?
  puts "Message sent successfully!"
  puts "Response: #{result.value!.message}"
else
  puts "Failed to send message: #{result.failure.message}"
end
```

### Check Account Balance

```ruby
# Check your account balance
balance_result = client.check_balance

if balance_result.success?
  balance = balance_result.value!.payload[:balance]
  puts "Your balance: #{balance}"
else
  puts "Failed to check balance: #{balance_result.failure.message}"
end
```

## Configuration

### Environment Variables

Set your API key as an environment variable:

```bash
export DIALOG_LK_ESMS_API_KEY="your_api_key_here"
```

Then use the configured client:

```ruby
# Uses API key from environment
client = DialogLkEsms.client(api_key: ENV['DIALOG_LK_ESMS_API_KEY'])
```

### Global Configuration

```ruby
DialogLkEsms.configure do |config|
  config.api_key = 'your_api_key_here'
  config.base_url = 'https://e-sms.dialog.lk/api/v1'  # Default
end
```

## API Reference

### Client Methods

#### `send_message`

Send SMS messages to one or more recipients.

```ruby
result = client.send_message(
  number_list: ['0771234567', '0777654321'],  # Array or single string
  message: 'Your message here',
  source_address: 'SENDER_ID',                # Your registered sender ID
  push_notification_url: 'https://your-callback-url.com'  # Optional
)
```

**Parameters:**
- `number_list` (String|Array) - Phone numbers to send to
- `message` (String) - SMS message content
- `source_address` (String) - Your registered sender ID
- `push_notification_url` (String, optional) - Callback URL for delivery reports

**Returns:** `Result::Success(SendResult)` or `Result::Failure(SendResult)`

#### `check_balance`

Check your account balance.

```ruby
result = client.check_balance
```

**Returns:** `Result::Success(BalanceResult)` or `Result::Failure(BalanceResult)`

### Result Objects

#### SendResult

```ruby
result = client.send_message(...)

if result.success?
  send_result = result.value!
  puts send_result.code      # Status code (e.g., "1" for success)
  puts send_result.ok        # Boolean success indicator
  puts send_result.message   # Human-readable message
  puts send_result.raw       # Raw API response
end
```

#### BalanceResult

```ruby
result = client.check_balance

if result.success?
  balance_result = result.value!
  puts balance_result.code                    # Status code
  puts balance_result.ok                      # Boolean success indicator
  puts balance_result.message                 # Human-readable message
  puts balance_result.payload[:balance]       # Balance amount (BigDecimal)
end
```

## Error Handling

The gem uses dry-monads for functional error handling. All methods return `Result` objects that can be either `Success` or `Failure`.

### Error Types

```ruby
# Configuration errors
DialogLkEsms::Errors::ConfigurationError

# Network/transport errors
DialogLkEsms::Errors::TransportError

# Parsing errors
DialogLkEsms::Errors::ParseError
```

### Example Error Handling

```ruby
result = client.send_message(
  number_list: '0771234567',
  message: 'Hello',
  source_address: 'SENDER'
)

case result
when Success
  puts "Message sent: #{result.value!.message}"
when Failure
  case result.failure
  when DialogLkEsms::Errors::ConfigurationError
    puts "Configuration error: #{result.failure.message}"
  when DialogLkEsms::Errors::TransportError
    puts "Network error: #{result.failure.message}"
  else
    puts "API error: #{result.failure.message}"
  end
end
```

## Status Codes

The API returns various status codes. Here are the common ones:

| Code | Message | Description |
|------|---------|-------------|
| `1` | Success | Message sent successfully |
| `2001` | Error occurred during campaign creation | General API error |
| `2002` | Bad request | Invalid request parameters |
| `2003` | Empty number list | No phone numbers provided |
| `2004` | Empty message body | No message content |
| `2005` | Invalid number list format | Malformed phone numbers |
| `2006` | Not eligible to send messages via GET requests | API access issue |
| `2007` | Invalid key | Invalid API key |
| `2008` | Insufficient balance or package quota | Not enough credits |
| `2009` | No valid numbers after mask-block removal | All numbers blocked |
| `2010` | Not eligible to consume packaging | Package access issue |
| `2011` | Transactional error | Transaction failed |

## Advanced Usage

### Multiple Recipients

```ruby
# Send to multiple numbers
result = client.send_message(
  number_list: ['0771234567', '0777654321', '0779876543'],
  message: 'Bulk message to multiple recipients',
  source_address: 'COMPANY'
)
```

### With Callback URL

```ruby
result = client.send_message(
  number_list: '0771234567',
  message: 'Message with delivery callback',
  source_address: 'SENDER',
  push_notification_url: 'https://your-app.com/sms-callback'
)
```

### Custom Base URL

```ruby
# Use custom API endpoint
client = DialogLkEsms.client(
  api_key: 'your_key',
  base_url: 'https://custom-api.dialog.lk/api/v1'
)
```

## Type Validation

The gem includes built-in type validation using dry-types:

```ruby
# Phone number validation
DialogLkEsms::Types::PhoneList.call(['0771234567'])  # Success
DialogLkEsms::Types::PhoneList.call(['123'])        # Failure - too short

# Message validation
DialogLkEsms::Types::MessageText.call('Hello')       # Success
DialogLkEsms::Types::MessageText.call('')            # Failure - empty

# Source address validation
DialogLkEsms::Types::SourceAddr.call('SENDER')       # Success
DialogLkEsms::Types::SourceAddr.call('')             # Failure - empty
```

## Testing

The gem includes comprehensive test coverage. Run tests with:

```bash
bundle exec ruby -Itest test/test_*.rb
```

## Requirements

- Ruby >= 2.6.0
- Valid Dialog eSMS API key
- Registered sender ID with Dialog

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run the tests:

```bash
bundle exec ruby -Itest test/test_*.rb
```

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sdglhm/dialog_lk_esms. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sdglhm/dialog_lk_esms/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DialogLkEsms project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sdglhm/dialog_lk_esms/blob/main/CODE_OF_CONDUCT.md).
