# frozen_string_literal: true

$LOAD_PATH << File.expand_path(__dir__)

require 'active_record'
require 'thor'
require 'pry'

Dir[File.join('lib', '**', '*.rb')].each do |path|
  require path
end

require 'db'

db_connection do
  Sequence.order(id: :asc).all.each do |sequence|
    color_sequence = ColorSequence.new(sequence.color)
    tsumo_state = TsumoState.new(color_sequence)
    map = tsumo_state.color_map

    pattern_sequence = sequence.color.tr(map.keys.join, map.values.join)
    sorted_pattern_sequence = pattern_sequence.chars.each_slice(2).map(&:sort).flatten.join

    sequence.update!(pattern: pattern_sequence, sorted_pattern: sorted_pattern_sequence)
  end

  # analyzer = SequenceAnalyzer.new

  binding.pry
end
