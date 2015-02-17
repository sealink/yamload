require 'yaml'
require 'ice_nine'
require 'yamload/loading'
require 'yamload/conversion'
require 'yamload/defaults'
require 'yamload/validation'

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

    def defaults=(defaults)
      defaults_merger.defaults = defaults
    end

    def defaults
      defaults_merger.defaults
    end

    def schema=(schema)
      validator.schema = schema
    end

    def schema
      validator.schema
    end

    def valid?
      validation_result.valid?
    end

    def validate!
      fail SchemaError, validation_result.error unless validation_result.valid?
    end

    def error
      validation_result.error
    end

    private

    def content_with_defaults
      defaults_merger.merge(@loader.content)
    end

    def defaults_merger
      @defaults_merger ||= Defaults::Hash.new
    end

    def validator
      @validator ||= Validation::Hash.new
    end

    def validation_result
      validator.validate(content)
    end
  end

  class SchemaError < StandardError; end
end
