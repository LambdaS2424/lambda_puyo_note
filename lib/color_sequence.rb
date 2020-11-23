# frozen_string_literal: true

class ColorSequence
  Tsumo = Struct.new(:oya, :ko)

  # @param pattern_string [String] e.g. 'gbybpyyppg...'
  def initialize(pattern_string)
    @pattern_string = pattern_string
  end

  def sequence
    @sequence ||= @pattern_string.chars.each_slice(2).map { |pair| Tsumo.new(pair[0], pair[1]) }
  end

  def to_s
    @pattern_string
  end

  def used_colors
    @used_colors ||= @pattern_string.chars.sort.uniq
  end
end
