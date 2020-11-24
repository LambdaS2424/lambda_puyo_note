# frozen_string_literal: true

require 'lib/field'

class ShapeField < Field
  def match?(field)
    raise ArgumentError, "TsumoField or ColorField is required. (but passed #{tsumo_field} (#{tsumo_field.class.name}))" unless field.is_a?(Field)

    groups.all? do |char, coordinates|
      next true if char == '*' # don't care
      coordinates.map { |c| field[c] }.uniq.size == 1
      # TODO: 隣接グループが異なる Tsumo であることをチェック
    end
  end

  def groups
    Hash[@field.group_by { |_, v| v }.sort.map { |k, v| [k, v.map(&:first) ]}]
  end
end
