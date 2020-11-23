# frozen_string_literal: true

class Node
  extend Forwardable
  def_delegators(:@params, *Hash.instance_methods(false))

  def initialize(params)
    @params = params
  end

  def to_sequence
    sequence = []
    current = @params
    loop do
      sequence << current[:tsumo]
      break unless current[:parent]
      current = current[:parent]
    end
    sequence.reverse.join
  end

  def id
    @id ||= "#{@params[:parent]&.id}#{@params[:tsumo]}"
  end
end
