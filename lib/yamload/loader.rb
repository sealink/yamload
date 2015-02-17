require 'yaml'
require 'ice_nine'
require 'yamload/loading'
require 'classy_hash'
require 'yamload/conversion'
require 'yamload/defaults'

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
      @content ||= IceNine.deep_freeze(content_with_defaults)
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

    def defaults=(defaults)
      defaults_merger.defaults = defaults
    end

    def defaults
      defaults_merger.defaults
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

    private

    def content_with_defaults
      defaults_merger.merge(@loader.content)
    end

    def defaults_merger
      @defaults_merger ||= Defaults::Hash.new
    end
  end

  class SchemaError < StandardError; end
end
