require 'facets/hash/rekey'
require 'anima'

module Yamload
  class HashToImmutableObject
    def initialize(hash)
      @hash = hash.rekey
    end

    def call
      immutable_objects_factory.new(converted_hash)
    end

    private

    def immutable_objects_factory
      anima = Anima.new(*@hash.keys)
      Class.new do
        include Adamantium
        include anima
      end
    end

    def converted_hash
      @hash.map.with_object({}) { |(key, value), hash|
        hash[key] = convert(value)
      }
    end

    def convert(value)
      if value.is_a?(Hash)
        self.class.new(value).call
      elsif value.is_a?(Array)
        value.map { |element| convert(element) }
      else
        value
      end
    end
  end
end
