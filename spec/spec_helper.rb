$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'support/coverage_loader'

require 'yamload'

current_file_dir = File.expand_path(File.dirname(__FILE__))
Yamload.dir = File.join(current_file_dir, 'fixtures')
