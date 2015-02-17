require 'yaml'
require 'ice_nine'
require 'yamload/loading'
require 'classy_hash'
require 'facets/hash/deep_merge'
require 'yamload/conversion'

module Yamload
  class Loader
    def initialize(file, dir = Yamload.dir)
      @loader = Loading::Yaml.new(file, dir)
    end

    def exist?
      @loader.exist?
    end

    # <b>DEPRECATED:</b> Please use <tt>content</tt> instead.
    def loaded_hash
      warn '[DEPRECATION] `loaded_hash` is deprecated.  Please use `content` instead.'
      content
    end

    def content
      @content ||= IceNine.deep_freeze(defaults.deep_merge(@loader.content))
    end

    def obj
      @immutable_obj ||= Conversion::Object.new(content).to_immutable
    end

    def reload
      @content = @immutable_obj = nil
      @loader.reload
      content
    end

    attr_writer :schema

    def schema
      @schema ||= {}
    end

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
      ClassyHash.validate(content, schema)
    rescue RuntimeError => e
      @error = e.message
      raise SchemaError, @error
    end

    def error
      return nil if valid?
      @error
    end
  end

  class SchemaError < StandardError; end
end
