# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "dialog_lk_esms"

require "minitest/autorun"
require "minitest/mock"
require "webmock/minitest"
require "bigdecimal"

# Configure WebMock
WebMock.disable_net_connect!(allow_localhost: true)
