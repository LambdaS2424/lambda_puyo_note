# frozen_string_literal: true

require 'forwardable'

class Node
  extend Forwardable
  def_delegators(:@params, *Hash.instance_methods(false))

  def initialize(params)
    @params = params
  end

  def to_pattern
    pattern = []
    current = @params
    loop do
      pattern << current[:tsumo]
      break unless current[:parent]
      current = current[:parent]
    end
    pattern.reverse.join
  end

  def id
    @id ||= "#{@params[:parent]&.id}#{@params[:tsumo]}"
  end
end
