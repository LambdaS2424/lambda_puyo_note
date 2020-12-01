# frozen_string_literal: true

class MoveState
  def self.all_patterns(depth, no_chigiri: false, initial_heights: Array.new(6, 0), for_pattern: nil)
    nodes = [
      MoveNode.new(
        heights: initial_heights,
        child_ids: []
      )
    ]

    pattern = for_pattern ? for_pattern.chars.each_slice(2).map { |(a, b)| a == b } : []

    result = []

    depth.times do |d|
      nodes = patterns(nodes, no_chigiri: no_chigiri, for_double: pattern[d])
      result << nodes # [d + 1, nodes, nodes.count]
    end

    result
  end

  def self.patterns(parents, no_chigiri: false, for_double: false)
    children = []
    parents.each do |node|
      Move.all(no_chigiri: no_chigiri, heights: node[:heights], for_double: for_double).each do |move|
        heights = move.occupations.each_with_object(Array.new(node[:heights])) { |index, arr| arr[index] += 1 }
        child = MoveNode.new(
          parent: node,
          move: move,
          heights: heights,
          child_ids: []
        )
        node[:child_ids] << child.id
        children << child
      end
    end

    children
  end
end
