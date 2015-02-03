require 'yaml'
require 'respect'

module Yamload
  class Loader
    def initialize(file, dir = Yamload.dir)
      @file = file
      @dir  = dir
    end

    def loaded_hash
      @loaded_hash ||= load
    end

    def obj
      @immutable_obj ||= HashToImmutableObject.new(loaded_hash).call
    end

    def reload
      @loaded_hash = @immutable_obj = nil
      loaded_hash
    end

    def define_schema
      @schema = Respect::HashSchema.define do |schema|
        yield schema
      end
    end

    def valid?
      return true if @schema.nil?
      @schema.validate? loaded_hash
    end

    def validate!
      return if valid?
      fail SchemaError, error
    end

    def error
      return nil if valid?
      @schema.last_error.message
    end

    private

    def load
      YAML.load_file(File.join(@dir, "#{@file}.yml"))
    end
  end

  class SchemaError < StandardError; end
end
