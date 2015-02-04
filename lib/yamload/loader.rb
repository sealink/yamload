require 'yaml'
require 'classy_hash'
require 'facets/hash/deep_merge'

module Yamload
  class Loader
    def initialize(file, dir = Yamload.dir)
      @file = file
      @dir  = dir
    end

    def exist?
      File.exist?(filepath)
    end

    def loaded_hash
      @loaded_hash ||= IceNine.deep_freeze(defaults.deep_merge(load))
    end

    def obj
      @immutable_obj ||= HashToImmutableObject.new(loaded_hash).call
    end

    def reload
      @loaded_hash = @immutable_obj = nil
      loaded_hash
    end

    attr_accessor :schema

    attr_writer :defaults

    def defaults
      @defaults ||= {}
    end

    def valid?
      validate!
      true
    rescue SchemaError
      false
    end

    def validate!
      @error = nil
      ClassyHash.validate(loaded_hash, @schema)
    rescue RuntimeError => e
      @error = e.message
      raise SchemaError, @error
    end

    def error
      return nil if valid?
      @error
    end

    private

    def load
      YAML.load_file(filepath)
    end

    def filepath
      File.join(@dir, "#{@file}.yml")
    end
  end

  class SchemaError < StandardError; end
end
