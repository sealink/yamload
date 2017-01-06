require 'classy_hash'

module Yamload
  module Validation
    class Hash
      attr_reader :schema

      def initialize(schema = nil)
        self.schema = schema
      end

      def schema=(schema)
        unless schema.is_a?(::Hash) || schema.nil?
          fail ArgumentError, "#{schema} is not a hash"
        end
        @schema = schema
      end

      def validate(hash)
        fail ArgumentError, "#{hash} is not a hash" unless hash.is_a?(::Hash)
        ClassyHash.validate(hash, @schema) unless @schema.nil?
        Result.new(true)
      rescue ClassyHash::SchemaViolationError => e
        Result.new(false, e.message)
      end
    end
  end
end
