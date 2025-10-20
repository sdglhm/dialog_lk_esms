# frozen_string_literal: true

require "uri"
require "net/http"
require "cgi"
require "bigdecimal"
require "dry-monads"
require "dialog_lk_esms/types"
require "dialog_lk_esms/errors"

module DialogLkEsms
  class Client
    include Dry::Monads[:result]
    include Dry::Monads[:do]
    
    STATUS_MESSAGES = {
      "1" => "Success",
      "2001" => "Error occurred during campaign creation",
      "2002" => "Bad request",
      "2003" => "Empty number list",
      "2004" => "Empty message body",
      "2005" => "Invalid number list format",
      "2006" => "Not eligible to send messages via GET requests",
      "2007" => "Invalid key (esmsqk parameter is invalid)",
      "2008" => "Insufficient balance or package quota",
      "2009" => "No valid numbers after mask-block removal",
      "2010" => "Not eligible to consume packaging",
      "2011" => "Transactional error"
    }
    
    SendResult = Struct.new(:code, :ok, :message, :raw, :payload, keyword_init: true)
    BalanceResult = Struct.new(:code, :ok, :message, :raw, :payload, keyword_init: true)
    
    def initialize(api_key:, base_url: "https://e-sms.dialog.lk/api/v1")
      @api_key = api_key
      @base_url = base_url.chomp("/")
      raise DialogLkEsms::Errors::ConfigurationError, "api_key is required" if @api_key.nil? || @api_key.empty?
    end
    
    def send_message(number_list:, message:, source_address:, push_notification_url: nil)
      numbers = Array(number_list).map(&:to_s).join(",")
      query = {
        esmsqk: @api_key,
        list: numbers,
        source_address: source_address.to_s,
        message: message.to_s
      }
      # Mirrors PHP sendMessage
      
      query[:push_notification_url] = push_notification_url.to_s if push_notification_url
      
      
      endpoint = "/message-via-url/create/url-campaign"
      raw = yield http_get(endpoint, query)
      
      
      code = raw.to_s.strip
      msg = STATUS_MESSAGES.fetch(code, "Unknown response: #{code}")
      ok = (code == "1")
      
      
      result = SendResult.new(code: code, ok: ok, message: msg, raw: raw)
      ok ? Success(result) : Failure(result)
    end
    
    
    # Mirrors PHP checkBalance
    # Returns Result::Success(BalanceResult) with payload: { balance: BigDecimal }
    # or Failure(BalanceResult)
    def check_balance
      endpoint = "/message-via-url/check/balance"
      query = { esmsqk: @api_key }
      raw = yield http_get(endpoint, query)
      
      
      status, balance_str = raw.to_s.split("|", 2)
      status = status&.strip.to_s
      
      
      if status.empty?
        result = BalanceResult.new(code: "parse_error", ok: false, message: "Unknown response or error", raw: raw)
        return Failure(result)
      end
      
      
      if status == "1"
        bd = coerce_decimal(balance_str)
        payload = { balance: bd }
        result = BalanceResult.new(code: status, ok: true, message: "Success", raw: raw, payload: payload)
        Success(result)
      else
        msg = STATUS_MESSAGES.fetch(status, "Unknown response or error")
        result = BalanceResult.new(code: status, ok: false, message: msg, raw: raw)
        Failure(result)
      end
    rescue => e
      Failure(BalanceResult.new(code: "exception", ok: false, message: e.message, raw: nil))
    end
    
    
    private
    
    
    def http_get(path, params)
      uri = URI.join(@base_url + "/", path.sub(%r{^/}, ""))
      uri.query = URI.encode_www_form(params)
      
      
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        req = Net::HTTP::Get.new(uri)
        http.request(req)
      end
      
      
      if res.is_a?(Net::HTTPSuccess)
        Success(res.body.to_s)
      else
        Failure(DialogLkEsms::Errors::TransportError.new("HTTP #{res.code}: #{res.body}"))
      end
    rescue SocketError, Timeout::Error, Errno::ECONNREFUSED => e
      Failure(DialogLkEsms::Errors::TransportError.new(e.message))
    end
    
    
    def coerce_decimal(str)
      s = (str || "0").to_s.strip
      BigDecimal(s)
    rescue ArgumentError
      BigDecimal("0")
    end
  end
end