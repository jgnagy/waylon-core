# frozen_string_literal: true

module Waylon
  # Used for working with the Moneta store for caching
  module Cache
    DefaultStorage = Moneta.new(
      :Redis,
      url: "redis://#{ENV.fetch("REDIS", "localhost:6379")}/1"
    )

    def self.clear
      storage.clear
    end

    def self.delete(key)
      storage.delete(key)
    end

    def self.key?(name)
      storage.key?(name)
    end

    def self.load(key, expires: nil)
      expires ? storage.load(key, expires: expires) : storage.load(key)
    end

    def self.store(key, value, expires: nil)
      if expires
        storage.store(key, value, expires: expires)
      else
        storage.store(key, value)
      end
    end

    def self.storage
      @storage ||= DefaultStorage
    end

    def self.storage=(storage)
      @storage = storage
    end
  end
end
