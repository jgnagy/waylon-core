# frozen_string_literal: true

module Waylon
  # Used for working with the Moneta store
  module Storage
    DefaultStorage = Moneta.new(
      :Redis,
      url: "redis://#{ENV.fetch("REDIS", "localhost:6379")}/2"
    )

    def self.cipher
      key_bytes = RbNaCl::Hash.sha256(ENV.fetch("ENCRYPTION_KEY", "thisisVeryUnsafe4U"))[0..31]
      RbNaCl::SimpleBox.from_secret_key(key_bytes)
    end

    def self.clear
      storage.clear
    end

    def self.delete(key)
      storage.delete(key)
    end

    def self.key?(name)
      storage.key?(name)
    end

    def self.load(key)
      this_cipher = cipher
      raw = storage.load(key)
      return nil unless raw

      decoded = Base64.decode64(raw)
      plain = this_cipher.decrypt(decoded)
      JSON.parse(plain)
    end

    def self.storage
      @storage ||= DefaultStorage
    end

    def self.storage=(storage)
      @storage = storage
    end

    def self.store(key, value)
      this_cipher = cipher
      encrypted = this_cipher.encrypt(value.to_json)
      encoded = Base64.encode64(encrypted)
      storage.store(key, encoded)
    end
  end
end
