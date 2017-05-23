# frozen_string_literal: true

module Tamashii
  # :nodoc:
  module Configurable
    # :nodoc:
    module ClassMethods
      def register(key, default, &_block)
        @defaults ||= {}
        return @defaults[key.to_sym] = yield if block_given?
        @defaults[key.to_sym] = default
      end

      def exist?(key)
        @defaults.key?(key.to_sym) || @defaults.key?(key.to_s[0..-2].to_sym)
      end

      def default_value(key)
        @defaults[key.to_sym]
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    def config(key, value = nil, &_block)
      @configs ||= {}
      return unless self.class.exist?(key)
      return @configs[key.to_sym] || self.class.default_value(key) if value.nil?
      return @configs[key.to_sym] = yield if block_given?
      @configs[key.to_sym] = value
    end

    def respond_to_missing?(name, _all = false)
      self.class.exist?(name)
    end

    def method_missing(name, *args, &block)
      return super unless self.class.exist?(name)
      return config(name.to_sym, nil, &block) unless name.to_s.end_with?('=')
      config(name.to_s[0..-2].to_sym, args.first)
    end
  end
end
