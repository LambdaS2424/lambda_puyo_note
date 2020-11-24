# frozen_string_literal: true

require 'lib/field'

class ShapeField < Field
  def match?(field)
    raise ArgumentError, "TsumoField or ColorField is required. (but passed #{tsumo_field} (#{tsumo_field.class.name}))" unless field.is_a?(Field)

    groups.all? do |char, coordinates|
      next true if char == '*' # don't care

      next false unless coordinates.map { |c| field[c] }.uniq.size == 1

      v = field[coordinates.first]
      surroundings(coordinates).all? { |c| field[c] != v }
    end
  end

  def groups
    Hash[@field.group_by { |_, v| v }.sort.map { |k, v| [k, v.map(&:first) ]}]
  end
end
