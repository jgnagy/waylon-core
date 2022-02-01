# frozen_string_literal: true

module Waylon
  module Services
    # A Ping Service for monitoring
    class Ping < Sinatra::Base
      configure do
        set :protection, except: :http_origin
        set :logging, ::Waylon::Logger
      end

      before do
        content_type "application/json"
        halt 403 unless request.get? || request.options?
      end

      after do
        headers "Access-Control-Allow-Methods" => %w[OPTIONS GET] if request.options?
      end

      get "/" do
        { status: :ok }.to_json
      end

      options "/" do
        halt 200
      end
    end
  end
end
