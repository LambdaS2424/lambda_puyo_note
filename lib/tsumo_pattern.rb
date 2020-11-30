# frozen_string_literal: true

class TsumoPattern
  def self.zenkeshi(depth, colors)
    Sequence.all.select do |sequence|
      pattern = sequence.sorted_pattern
      # 登場するぷよを色別にグルーピング
      group = pattern[0..(2 * depth) - 1].chars.group_by(&:itself)
      group.values.all? { |v| v.size >= 4 } && group.keys.count == colors
    end
  end
end
