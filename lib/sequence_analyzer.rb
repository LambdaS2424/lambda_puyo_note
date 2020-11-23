# frozen_string_literal:; true

class SequenceAnalyzer
  def initialize
    @sequences = Sequence.all
  end

  def distribution(n = 2)
    range = 0..(n.to_i * 2 - 1)
    Hash[@sequences.map(&:sorted_pattern).map { |pat| pat[range] }.group_by(&:itself).map { |k, v| [k, v.size] }]    
  end
end
