# frozen_string_literal: true

PROJECT_ROOT = File.expand_path(File.join(__dir__)) 
$LOAD_PATH << PROJECT_ROOT

require 'active_record'
require 'thor'
require 'pry'

require 'db'

Dir[File.join(PROJECT_ROOT, 'lib', '**', '*.rb')].each do |path|
  require path
end
