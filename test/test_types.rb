# frozen_string_literal: true

require "test_helper"

class TestTypes < Minitest::Test
  def test_phone_list_type_valid_numbers
    valid_numbers = ["0771234567", "+94771234567", "1234567890"]
    
    valid_numbers.each do |number|
      result = DialogLkEsms::Types::PhoneList.call([number])
      assert result.success?
      assert_equal [number], result.value!
    end
  end

  def test_phone_list_type_invalid_numbers
    invalid_numbers = ["123", "abc", "12345", "12345678901234567890"]
    
    invalid_numbers.each do |number|
      result = DialogLkEsms::Types::PhoneList.call([number])
      assert result.failure?
    end
  end

  def test_phone_list_type_empty_array
    result = DialogLkEsms::Types::PhoneList.call([])
    assert result.success?
    assert_equal [], result.value!
  end

  def test_message_text_type_valid
    valid_messages = ["Hello", "Test message", "a", "This is a long message with spaces"]
    
    valid_messages.each do |message|
      result = DialogLkEsms::Types::MessageText.call(message)
      assert result.success?
      assert_equal message, result.value!
    end
  end

  def test_message_text_type_invalid
    invalid_messages = ["", nil]
    
    invalid_messages.each do |message|
      result = DialogLkEsms::Types::MessageText.call(message)
      assert result.failure?
    end
  end

  def test_source_addr_type_valid
    valid_addresses = ["TEST", "SENDER", "Company", "a"]
    
    valid_addresses.each do |address|
      result = DialogLkEsms::Types::SourceAddr.call(address)
      assert result.success?
      assert_equal address, result.value!
    end
  end

  def test_source_addr_type_invalid
    invalid_addresses = ["", nil]
    
    invalid_addresses.each do |address|
      result = DialogLkEsms::Types::SourceAddr.call(address)
      assert result.failure?
    end
  end

  def test_status_code_type
    valid_codes = ["1", "2001", "2002", "Success", "Error"]
    
    valid_codes.each do |code|
      result = DialogLkEsms::Types::StatusCode.call(code)
      assert result.success?
      assert_equal code, result.value!
    end
  end

  def test_balance_type_with_decimal
    balance = BigDecimal("100.50")
    result = DialogLkEsms::Types::Balance.call(balance)
    assert result.success?
    assert_equal balance, result.value!
  end

  def test_balance_type_with_float
    balance = 100.50
    result = DialogLkEsms::Types::Balance.call(balance)
    assert result.success?
    assert_equal balance, result.value!
  end

  def test_balance_type_with_string_decimal
    balance = "100.50"
    result = DialogLkEsms::Types::Balance.call(balance)
    assert result.success?
    assert_equal BigDecimal("100.50"), result.value!
  end

  def test_balance_type_with_string_float
    balance = "100.50"
    result = DialogLkEsms::Types::Balance.call(balance)
    assert result.success?
    assert_equal BigDecimal("100.50"), result.value!
  end

  def test_response_struct_valid
    valid_response = {
      code: "1",
      ok: true,
      message: "Success",
      raw: "1",
      payload: { balance: BigDecimal("100.50") }
    }
    
    result = DialogLkEsms::Types::ResponseStruct.call(valid_response)
    assert result.success?
    assert_equal valid_response, result.value!
  end

  def test_response_struct_minimal
    minimal_response = {
      code: "1",
      ok: true,
      message: "Success"
    }
    
    result = DialogLkEsms::Types::ResponseStruct.call(minimal_response)
    assert result.success?
    assert_equal minimal_response, result.value!
  end

  def test_response_struct_invalid_missing_required_fields
    invalid_response = {
      code: "1",
      ok: true
      # missing message
    }
    
    result = DialogLkEsms::Types::ResponseStruct.call(invalid_response)
    assert result.failure?
  end

  def test_response_struct_invalid_wrong_types
    invalid_response = {
      code: 1,  # should be string
      ok: "true",  # should be boolean
      message: "Success"
    }
    
    result = DialogLkEsms::Types::ResponseStruct.call(invalid_response)
    assert result.failure?
  end

  def test_types_module_includes_dry_types
    assert DialogLkEsms::Types.respond_to?(:call)
    assert DialogLkEsms::Types.respond_to?(:[])
  end

  def test_types_are_accessible
    assert_respond_to DialogLkEsms::Types, :PhoneList
    assert_respond_to DialogLkEsms::Types, :MessageText
    assert_respond_to DialogLkEsms::Types, :SourceAddr
    assert_respond_to DialogLkEsms::Types, :StatusCode
    assert_respond_to DialogLkEsms::Types, :Balance
    assert_respond_to DialogLkEsms::Types, :ResponseStruct
  end

  def test_phone_list_constraint_format
    # Test the regex constraint for phone numbers
    valid_formats = [
      "+94771234567",  # International format
      "0771234567",    # Local format
      "1234567890",    # 10 digits
      "123456789012345" # 15 digits (max)
    ]
    
    valid_formats.each do |number|
      result = DialogLkEsms::Types::PhoneList.call([number])
      assert result.success?, "Failed for number: #{number}"
    end
    
    invalid_formats = [
      "12345",         # Too short
      "12345678901234567890", # Too long
      "abc123",        # Contains letters
      "+abc123"        # Invalid format
    ]
    
    invalid_formats.each do |number|
      result = DialogLkEsms::Types::PhoneList.call([number])
      assert result.failure?, "Should have failed for number: #{number}"
    end
  end
end
