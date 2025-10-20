# frozen_string_literal: true

module DialogLkEsms
  module Errors
    class Error < StandardError; end
    
    class ConfigurationError < Error; end
    class TransportError < Error; end
    class ParseError < Error; end
    class Error < StandardError; end
  end
end