# frozen_string_literal: true

require 'forwardable'

class TsumoNode
  extend Forwardable
  def_delegators(:@params, *Hash.instance_methods(false))

  # @param :parent
  # @param :tsumo
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
