# frozen_string_literal: true

module Waylon
  # Used for working with the Moneta store
  module Storage
    DefaultStorage = Moneta.new(
      :Redis,
      url: "redis://#{ENV.fetch("REDIS", "localhost:6379")}/2"
    )

    def self.adapter
      storage.adapter
    end

    def self.cipher
      key_bytes = RbNaCl::Hash.sha256(encryption_key)[0..31]
      RbNaCl::SimpleBox.from_secret_key(key_bytes)
    end

    def self.clear
      storage.clear
    end

    def self.delete(key)
      storage.delete(key)
    end

    def self.each_key(&block)
      storage.each_key(&block)
    end

    def self.encryption_key
      ENV.fetch("ENCRYPTION_KEY", "thisisVeryUnsafe4U")
    end

    def self.encryption_key_fingerprint
      base = RbNaCl::Hash.sha256(encryption_key)[0..15]
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(base)[0..7])
    end

    def self.key?(name)
      storage.key?(name)
    end

    def self.load(key)
      this_cipher = cipher
      raw = storage.load(key)
      return nil unless raw

      wrapper = JSON.parse(raw)
      value = wrapper["data"]
      return nil unless value

      decoded = Base64.decode64(value)
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
      wrapper = { cipher: cipher.class.name, data: encoded, key: encryption_key_fingerprint }
      storage.store(key, wrapper.to_json)
    end
  end
end
