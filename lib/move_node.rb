# frozen_string_literal: true

require 'delegate'

class MoveNode < DelegateClass(Hash)
  # @param :parent [MoveNode]
  # @param :move [Move::M_]
  # @param :heights [Array] 各列の高さ
  def initialize(params)
    super(params)
  end

  def to_pattern
    pattern = []
    current = self
    loop do
      break unless current[:parent]
      pattern << current[:move]
      current = current[:parent]
    end
    pattern.reverse
  end

  # def to_moves
  #   moves = []
  #   current = self
  #   loop do
  #     moves << current[:move]
      
  #   end
  # end
  
  def id
    @id ||= "#{self[:parent]&.id}#{self[:move]}"
  end
end
