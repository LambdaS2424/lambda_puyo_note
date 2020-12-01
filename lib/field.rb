# frozen_string_literal: true

require 'forwardable'
require 'set'

class Field
  extend Forwardable

  attr_reader :field
  attr_reader :errors

  PUYO_OBJECTS = '1234'
  EMPTY_FIELD = Hash[(1..6).to_a.map { |col| (1..14).to_a.map { |row| [[col, row], '_'] } }.flatten(1)].freeze

  def_delegators :@field, :[]

  def self.load(file:)
    result = {}

    shape_str = File.read(file)

    cols = shape_str.split("\n").map(&:chars).reverse.transpose
    cols.each_with_index do |rows, col_index|
      col = col_index + 1
      rows.each_with_index do |value, row_index|
        row = row_index + 1
        result[[col, row]] = value
      end
    end

    f = new(result)

    unless f.valid?
      warn f.errors
      return
    end

    f
  end

  def initialize(field = nil)
    @field = field || EMPTY_FIELD.dup
  end

  def valid?
    @errors ||= []
    @field.keys.each do |(col, row)|
      @errors << "out of col range at (#{col}, #{row})" unless col.between?(1, 6)
      @errors << "out of row range at (#{col}, #{row})" unless row.between?(1, 14)
    end

    @errors.empty?
  end

  def put_on_top(column, value)
    @field[[column, height(column) + 1]] = value
  end

  def surrounding(coordinate)
    col, row = coordinate

    [
      [col - 1, row],
      [col + 1, row],
      [col, row - 1],
      [col, row + 1]
    ]
  end

  def surroundings(coordinates)
    coordinates.map { |coordinate| surrounding(coordinate) }.flatten(1) - coordinates
  end

  # num_to_vanish 以上連結したぷよを消す ('_' にする)
  def vanish(num_to_vanish: 4)
    vanished = {}

    group_field_value.each do |_, marks|
      if marks.size >= num_to_vanish
        type = @field[marks.first.first]
        vanished[type] ||= []
        vanished[type] << marks.count
        marks.each { |(coord, _)| @field[coord] = '_' }
      end
    end

    vanished
  end

  # ぷよが存在しない空間を埋める
  def pack
    tmp = @field.dup
    @field = EMPTY_FIELD.dup
    tmp.sort.each do |(col, row), value|
      put_on_top(col, value)
    end
  end

  # #vanish, #pack を安定形になるまで繰り返す
  def play
    stats = []

    loop do
      pack
      vanished = vanish

      break if vanished.empty?

      stats << vanished
    end

    pack
    stats
  end

  def height(column)
    @field.select { |k, c| k[0] == column && c =~ /[#{self.class::PUYO_OBJECTS}]/ }.count
  end

  def heights
    @field.group_by { |k, v| k[0] }.map { |_, v| v.count { |_, c| c =~ /[#{self.class::PUYO_OBJECTS}]/  } }
  end

  def to_s
    @field.group_by { |k, _| k[1] }.map { |_, v| v.map(&:second).join }.reverse.join("\n")
  end

  # 発火可能な座標と色を返す
  #
  # すでに 4連結以上している箇所がない前提
  def start_points
    result = Set.new
    candidates = group_field_value.select { |_, coords| coords.size == 3 }
    candidates.each do |_, coords|
      coords.each do |coord, _|
        surrounding(coord).each do |c|
          result << [c, @field[coord]] if @field[c] == '_'
        end
      end
    end

    result
  end

  private

  # 隣接する同じ値の座標をグルーピングする
  #
  # === Return
  # グループ番号をキーにした Hash [Hash]
  # e.g.) { 0 => [[1, 1], [1, 2]], 1 => [[2, 1], [2, 2] } }
  def group_field_value
    placed_field = @field.select { |_, c| c =~ /[#{self.class::PUYO_OBJECTS}]/  }
    count = placed_field.count
    return {} if count == 0 

    marks = {}
    group_no = 0
    current_field_value = nil

    placed_field.each do |coord, current_field_value|
      next if marks[coord]

      catch(:placed_field_loop) do
        marks[coord] = group_no
        current_targets = (surrounding(coord) & placed_field.keys) - marks.keys

        # 同じ group_no のラッベル付け
        loop do
          throw :placed_field_loop if current_targets.empty?

          current_targets = current_targets.map do |c|
            if placed_field[c] == current_field_value
              marks[c] = group_no
              surrounding(c) & placed_field.keys - marks.keys
            end
          end.flatten(1).compact
          
        end
      end

      group_no += 1
    end

    marks.group_by(&:second)
  end
end
