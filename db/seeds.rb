# frozen_string_literal: true

PROJECT_ROOT = File.expand_path(File.join(__dir__, '..')) 
$LOAD_PATH << PROJECT_ROOT

require 'active_record'
require 'pry'

Dir[File.join(PROJECT_ROOT, 'lib', '**', '*.rb')].each do |path|
  require path
end

require 'db'

db_connection do
  pattern_strings = Haipuyo.load(File.join(__dir__, 'resources', 'haipuyo.txt'))

  pattern_strings.each do |pattern_string|
    color_sequence = ColorSequence.new(pattern_string)

    Sequence.create(color: color_sequence.to_s)
  end
end
