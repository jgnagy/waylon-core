# frozen_string_literal: true

module Waylon
  # Base class for Webhooks
  class Webhook < Sinatra::Base
    include BaseComponent

    # Config namespace for config keys
    # @return [String] The namespace for config keys
    def self.config_namespace
      "webhooks.#{component_namespace}"
    end

    # Places the incoming request body onto the Senses queue for processing by workers
    # @param [Hash] content The verified request body
    def enqueue(content)
      Resque.enqueue sense_class, content
    end

    # Provides the Sense class that corresponds to this Webhook, with some sensible assumptions
    # @return [Class] The name of the corresponding Sense class
    def sense_class
      last = self.class.name.split("::").last
      Module.const_get("Senses::#{last}")
    end

    # This must be implemented on every Webhook to provide a mechanism to ensure received payloads are legit
    # @param [String] _payload The raw, unparsed request body
    # @param [Hash] _headers The raw, unparsed request headers as a Hash
    # @return [Boolean]
    def verify(_payload, _headers)
      raise GenericException, "Not Implemented"
    end

    configure do
      set :protection, except: :http_origin
      set :logging, ::Waylon::Logger
    end

    before do
      content_type "application/json"

      begin
        unless request.get? || request.options?
          request.body.rewind
          @parsed_body = JSON.parse(request.body.read, symbolize_names: true)
        end
      rescue StandardError => e
        halt(400, { error: "Request must be JSON: #{e.message}" }.to_json)
      end
    end

    after do
      request.options? && headers("Access-Control-Allow-Methods" => @allowed_types || %w[OPTIONS POST])
    end

    post "/" do
      begin
        request.body.rewind
        verify request.body.read, request.env
        enqueue @parsed_body
      rescue StandardError => e
        halt(422, { error: "Unprocessable entity: #{e.message}" }.to_json)
      end

      { status: :ok }.to_json
    end

    options "/" do
      halt 200
    end
  end
end
