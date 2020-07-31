require 'yaml'
require 'ice_nine'
require 'aws-sdk-secretsmanager'
require 'aws-sdk-ssm'

require 'yamload/loading'
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

    private

    def content_with_defaults
      defaults_merger.merge(@loader.content)
    end

    def defaults_merger
      @defaults_merger ||= Defaults::Hash.new
    end
  end
end
