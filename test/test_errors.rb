# frozen_string_literal: true

require "test_helper"

class TestErrors < Minitest::Test
  def test_error_inheritance
    assert DialogLkEsms::Errors::Error < StandardError
    assert DialogLkEsms::Errors::ConfigurationError < DialogLkEsms::Errors::Error
    assert DialogLkEsms::Errors::TransportError < DialogLkEsms::Errors::Error
    assert DialogLkEsms::Errors::ParseError < DialogLkEsms::Errors::Error
  end

  def test_configuration_error_can_be_raised
    error = DialogLkEsms::Errors::ConfigurationError.new("API key is required")
    assert_equal "API key is required", error.message
    assert_instance_of DialogLkEsms::Errors::ConfigurationError, error
  end

  def test_transport_error_can_be_raised
    error = DialogLkEsms::Errors::TransportError.new("Connection refused")
    assert_equal "Connection refused", error.message
    assert_instance_of DialogLkEsms::Errors::TransportError, error
  end

  def test_parse_error_can_be_raised
    error = DialogLkEsms::Errors::ParseError.new("Invalid response format")
    assert_equal "Invalid response format", error.message
    assert_instance_of DialogLkEsms::Errors::ParseError, error
  end

  def test_errors_can_be_rescued_by_base_error
    begin
      raise DialogLkEsms::Errors::ConfigurationError, "Test error"
    rescue DialogLkEsms::Errors::Error => e
      assert_equal "Test error", e.message
      assert_instance_of DialogLkEsms::Errors::ConfigurationError, e
    end
  end

  def test_errors_can_be_rescued_by_standard_error
    begin
      raise DialogLkEsms::Errors::TransportError, "Network error"
    rescue StandardError => e
      assert_equal "Network error", e.message
      assert_instance_of DialogLkEsms::Errors::TransportError, e
    end
  end

  def test_error_namespace_isolation
    # Ensure errors are properly namespaced
    assert_equal "DialogLkEsms::Errors::ConfigurationError", 
                 DialogLkEsms::Errors::ConfigurationError.name
    assert_equal "DialogLkEsms::Errors::TransportError", 
                 DialogLkEsms::Errors::TransportError.name
    assert_equal "DialogLkEsms::Errors::ParseError", 
                 DialogLkEsms::Errors::ParseError.name
  end
end
