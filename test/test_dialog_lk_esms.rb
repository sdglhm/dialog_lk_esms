# frozen_string_literal: true

require "test_helper"

class TestDialogLkEsms < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::DialogLkEsms::VERSION
    assert_equal "0.1.0", ::DialogLkEsms::VERSION
  end

  def test_module_configuration
    # Test default configuration
    assert_equal "https://e-sms.dialog.lk/api/v1", DialogLkEsms.config.base_url
    
    # Test API key from environment
    ENV["DIALOG_LK_ESMS_API_KEY"] = "test_key"
    assert_equal "test_key", DialogLkEsms.config.api_key.call
  ensure
    ENV.delete("DIALOG_LK_ESMS_API_KEY")
  end

  def test_client_factory_method
    client = DialogLkEsms.client(api_key: "test_key")
    assert_instance_of DialogLkEsms::Client, client
    assert_equal "test_key", client.instance_variable_get(:@api_key)
    assert_equal "https://e-sms.dialog.lk/api/v1", client.instance_variable_get(:@base_url)
  end

  def test_client_factory_method_with_custom_base_url
    client = DialogLkEsms.client(api_key: "test_key", base_url: "https://custom.example.com")
    assert_instance_of DialogLkEsms::Client, client
    assert_equal "test_key", client.instance_variable_get(:@api_key)
    assert_equal "https://custom.example.com", client.instance_variable_get(:@base_url)
  end

  def test_error_class_exists
    assert DialogLkEsms::Errors::Error < StandardError
  end

  def test_module_includes_dry_configurable
    assert DialogLkEsms.respond_to?(:config)
    assert DialogLkEsms.respond_to?(:setting)
  end

  def test_all_required_modules_are_loaded
    assert defined?(DialogLkEsms::Client)
    assert defined?(DialogLkEsms::Errors)
    assert defined?(DialogLkEsms::Types)
    assert defined?(DialogLkEsms::VERSION)
  end

  def test_configuration_settings
    # Test that settings are properly defined
    assert DialogLkEsms.config.respond_to?(:api_key)
    assert DialogLkEsms.config.respond_to?(:base_url)
    
    # Test default values
    assert_equal "https://e-sms.dialog.lk/api/v1", DialogLkEsms.config.base_url
    assert_instance_of Proc, DialogLkEsms.config.api_key
  end

  def test_configuration_can_be_modified
    original_base_url = DialogLkEsms.config.base_url
    
    DialogLkEsms.configure do |config|
      config.base_url = "https://custom.example.com"
    end
    
    assert_equal "https://custom.example.com", DialogLkEsms.config.base_url
  ensure
    DialogLkEsms.configure do |config|
      config.base_url = original_base_url
    end
  end

  def test_api_key_from_environment
    ENV["DIALOG_LK_ESMS_API_KEY"] = "env_test_key"
    
    # Reload the module to pick up the environment variable
    load File.expand_path("../lib/dialog_lk_esms.rb", __dir__)
    
    assert_equal "env_test_key", DialogLkEsms.config.api_key.call
  ensure
    ENV.delete("DIALOG_LK_ESMS_API_KEY")
    # Reload the module to reset
    load File.expand_path("../lib/dialog_lk_esms.rb", __dir__)
  end

  def test_api_key_defaults_to_nil_when_not_in_environment
    ENV.delete("DIALOG_LK_ESMS_API_KEY")
    
    # Reload the module to pick up the environment variable
    load File.expand_path("../lib/dialog_lk_esms.rb", __dir__)
    
    # The default proc should return nil when ENV variable is not set
    assert_nil DialogLkEsms.config.api_key.call
  ensure
    # Reload the module to reset
    load File.expand_path("../lib/dialog_lk_esms.rb", __dir__)
  end
end
