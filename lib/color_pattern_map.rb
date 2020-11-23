# frozen_string_literal: true

class ColorPatternMap
  def initialize(color_sequence)
    @pattern_to_color = Hash[Puyo::Pattern.all.map { |pat| [pat, color_sequence.used_colors] }]
  end

  def []=(pattern, colors)
    @pattern_to_color[pattern] = colors
  end

  def [](pattern)
    @pattern_to_color[pattern]
  end

  def fix(pattern, color)
    @pattern_to_color.each do |k, v|
      v.delete(color)
    end
    @pattern_to_color[pattern] = [color]
  end

  def fixed?
    @pattern_to_color.all? { |pat, colors| colors.size == 1 }
  end

  def to_h
    @pattern_to_color
  end

  def to_color_map
    Hash[@pattern_to_color.map { |k, v| [v.first, k] }]
  end
end
