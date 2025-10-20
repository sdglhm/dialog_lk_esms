# frozen_string_literal: true

require "test_helper"

class TestClient < Minitest::Test
  def setup
    @client = DialogLkEsms::Client.new(api_key: "test_api_key")
  end

  def test_initialization_with_valid_api_key
    client = DialogLkEsms::Client.new(api_key: "valid_key")
    assert_equal "valid_key", client.instance_variable_get(:@api_key)
    assert_equal "https://e-sms.dialog.lk/api/v1", client.instance_variable_get(:@base_url)
  end

  def test_initialization_with_custom_base_url
    client = DialogLkEsms::Client.new(api_key: "valid_key", base_url: "https://custom.example.com")
    assert_equal "https://custom.example.com", client.instance_variable_get(:@base_url)
  end

  def test_initialization_with_trailing_slash_in_base_url
    client = DialogLkEsms::Client.new(api_key: "valid_key", base_url: "https://e-sms.dialog.lk/api/v1/")
    assert_equal "https://e-sms.dialog.lk/api/v1", client.instance_variable_get(:@base_url)
  end

  def test_initialization_raises_error_with_nil_api_key
    assert_raises(DialogLkEsms::Errors::ConfigurationError) do
      DialogLkEsms::Client.new(api_key: nil)
    end
  end

  def test_initialization_raises_error_with_empty_api_key
    assert_raises(DialogLkEsms::Errors::ConfigurationError) do
      DialogLkEsms::Client.new(api_key: "")
    end
  end

  def test_send_message_success
    stub_request(:get, "https://e-sms.dialog.lk/api/v1/message-via-url/create/url-campaign")
      .with(query: {
        esmsqk: "test_api_key",
        list: "0771234567",
        source_address: "TEST",
        message: "Hello World"
      })
      .to_return(status: 200, body: "1")

    result = @client.send_message(
      number_list: "0771234567",
      message: "Hello World",
      source_address: "TEST"
    )

    assert result.success?
    assert_equal "1", result.value!.code
    assert result.value!.ok
    assert_equal "Success", result.value!.message
  end

  def test_send_message_with_multiple_numbers
    stub_request(:get, "https://e-sms.dialog.lk/api/v1/message-via-url/create/url-campaign")
      .with(query: {
        esmsqk: "test_api_key",
        list: "0771234567,0777654321",
        source_address: "TEST",
        message: "Hello World"
      })
      .to_return(status: 200, body: "1")

    result = @client.send_message(
      number_list: ["0771234567", "0777654321"],
      message: "Hello World",
      source_address: "TEST"
    )

    assert result.success?
  end

  def test_send_message_with_push_notification_url
    stub_request(:get, "https://e-sms.dialog.lk/api/v1/message-via-url/create/url-campaign")
      .with(query: {
        esmsqk: "test_api_key",
        list: "0771234567",
        source_address: "TEST",
        message: "Hello World",
        push_notification_url: "https://example.com/callback"
      })
      .to_return(status: 200, body: "1")

    result = @client.send_message(
      number_list: "0771234567",
      message: "Hello World",
      source_address: "TEST",
      push_notification_url: "https://example.com/callback"
    )

    assert result.success?
  end

  def test_send_message_failure
    stub_request(:get, "https://e-sms.dialog.lk/api/v1/message-via-url/create/url-campaign")
      .with(query: {
        esmsqk: "test_api_key",
        list: "0771234567",
        source_address: "TEST",
        message: "Hello World"
      })
      .to_return(status: 200, body: "2002")

    result = @client.send_message(
      number_list: "0771234567",
      message: "Hello World",
      source_address: "TEST"
    )

    assert result.failure?
    assert_equal "2002", result.failure.code
    assert_equal false, result.failure.ok
    assert_equal "Bad request", result.failure.message
  end

  def test_send_message_unknown_status_code
    stub_request(:get, "https://e-sms.dialog.lk/api/v1/message-via-url/create/url-campaign")
      .with(query: {
        esmsqk: "test_api_key",
        list: "0771234567",
        source_address: "TEST",
        message: "Hello World"
      })
      .to_return(status: 200, body: "9999")

    result = @client.send_message(
      number_list: "0771234567",
      message: "Hello World",
      source_address: "TEST"
    )

    assert result.failure?
    assert_equal "9999", result.failure.code
    assert_equal false, result.failure.ok
    assert_equal "Unknown response: 9999", result.failure.message
  end

  def test_send_message_http_error
    stub_request(:get, "https://e-sms.dialog.lk/api/v1/message-via-url/create/url-campaign")
      .with(query: {
        esmsqk: "test_api_key",
        list: "0771234567",
        source_address: "TEST",
        message: "Hello World"
      })
      .to_return(status: 500, body: "Internal Server Error")

    result = @client.send_message(
      number_list: "0771234567",
      message: "Hello World",
      source_address: "TEST"
    )

    assert result.failure?
    assert_instance_of DialogLkEsms::Errors::TransportError, result.failure
  end

  def test_send_message_network_error
    stub_request(:get, "https://e-sms.dialog.lk/api/v1/message-via-url/create/url-campaign")
      .with(query: {
        esmsqk: "test_api_key",
        list: "0771234567",
        source_address: "TEST",
        message: "Hello World"
      })
      .to_raise(SocketError.new("Connection refused"))

    result = @client.send_message(
      number_list: "0771234567",
      message: "Hello World",
      source_address: "TEST"
    )

    assert result.failure?
    assert_instance_of DialogLkEsms::Errors::TransportError, result.failure
  end

  def test_check_balance_success
    stub_request(:get, "https://e-sms.dialog.lk/api/v1/message-via-url/check/balance")
      .with(query: { esmsqk: "test_api_key" })
      .to_return(status: 200, body: "1|100.50")

    result = @client.check_balance

    assert result.success?
    assert_equal "1", result.value!.code
    assert result.value!.ok
    assert_equal "Success", result.value!.message
    assert_equal BigDecimal("100.50"), result.value!.payload[:balance]
  end

  def test_check_balance_failure
    stub_request(:get, "https://e-sms.dialog.lk/api/v1/message-via-url/check/balance")
      .with(query: { esmsqk: "test_api_key" })
      .to_return(status: 200, body: "2008")

    result = @client.check_balance

    assert result.failure?
    assert_equal "2008", result.failure.code
    assert_equal false, result.failure.ok
    assert_equal "Insufficient balance or package quota", result.failure.message
  end

  def test_check_balance_parse_error
    stub_request(:get, "https://e-sms.dialog.lk/api/v1/message-via-url/check/balance")
      .with(query: { esmsqk: "test_api_key" })
      .to_return(status: 200, body: "")

    result = @client.check_balance

    assert result.failure?
    assert_equal "parse_error", result.failure.code
    assert_equal false, result.failure.ok
    assert_equal "Unknown response or error", result.failure.message
  end

  def test_check_balance_invalid_balance_format
    stub_request(:get, "https://e-sms.dialog.lk/api/v1/message-via-url/check/balance")
      .with(query: { esmsqk: "test_api_key" })
      .to_return(status: 200, body: "1|invalid_balance")

    result = @client.check_balance

    assert result.success?
    assert_equal BigDecimal("0"), result.value!.payload[:balance]
  end

  def test_check_balance_network_error
    stub_request(:get, "https://e-sms.dialog.lk/api/v1/message-via-url/check/balance")
      .with(query: { esmsqk: "test_api_key" })
      .to_raise(Timeout::Error.new("Request timeout"))

    result = @client.check_balance

    assert result.failure?
    assert_equal "exception", result.failure.code
    assert_equal false, result.failure.ok
    # The exception message might be empty for Timeout::Error
    assert_equal "", result.failure.message
  end

  def test_status_messages_constant
    status_messages = DialogLkEsms::Client::STATUS_MESSAGES
    
    assert_equal "Success", status_messages["1"]
    assert_equal "Error occurred during campaign creation", status_messages["2001"]
    assert_equal "Bad request", status_messages["2002"]
    assert_equal "Empty number list", status_messages["2003"]
    assert_equal "Empty message body", status_messages["2004"]
    assert_equal "Invalid number list format", status_messages["2005"]
    assert_equal "Not eligible to send messages via GET requests", status_messages["2006"]
    assert_equal "Invalid key (esmsqk parameter is invalid)", status_messages["2007"]
    assert_equal "Insufficient balance or package quota", status_messages["2008"]
    assert_equal "No valid numbers after mask-block removal", status_messages["2009"]
    assert_equal "Not eligible to consume packaging", status_messages["2010"]
    assert_equal "Transactional error", status_messages["2011"]
  end

  def test_send_result_struct
    result = DialogLkEsms::Client::SendResult.new(
      code: "1",
      ok: true,
      message: "Success",
      raw: "1"
    )

    assert_equal "1", result.code
    assert result.ok
    assert_equal "Success", result.message
    assert_equal "1", result.raw
    assert_nil result.payload
  end

  def test_balance_result_struct
    result = DialogLkEsms::Client::BalanceResult.new(
      code: "1",
      ok: true,
      message: "Success",
      raw: "1|100.50",
      payload: { balance: BigDecimal("100.50") }
    )

    assert_equal "1", result.code
    assert result.ok
    assert_equal "Success", result.message
    assert_equal "1|100.50", result.raw
    assert_equal BigDecimal("100.50"), result.payload[:balance]
  end
end
