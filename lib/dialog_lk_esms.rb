# frozen_string_literal: true

require_relative "dialog_lk_esms/version"
require "dry-configurable"
require "dry-types"
require "dry-monads"
require_relative "dialog_lk_esms/client"
require_relative "dialog_lk_esms/errors"
require_relative "dialog_lk_esms/types"

module DialogLkEsms
  extend Dry::Configurable

  setting :api_key, default: -> { ENV["DIALOG_LK_ESMS_API_KEY"] }, reader: true
  setting :base_url, default: "https://e-sms.dialog.lk/api/v1", reader: true

  def self.client(api_key:, base_url: "https://e-sms.dialog.lk/api/v1")
    Client.new api_key: api_key, base_url: base_url
  end

end
