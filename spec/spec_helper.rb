$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "support/coverage_loader"

require "yamload"

require "aws-sdk-ssm"
require "aws-sdk-secretsmanager"

current_file_dir = __dir__
Yamload.dir = File.join(current_file_dir, "fixtures")
