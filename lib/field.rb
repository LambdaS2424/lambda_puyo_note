# frozen_string_literal: true

require 'forwardable'

class Field
  extend Forwardable

  attr_reader :field
  attr_reader :errors

  PUYO_OBJECTS = '1234'

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
    @field = field || Hash[(1..6).to_a.map { |col| (1..14).to_a.map { |row| [[col, row], '_'] } }.flatten(1)]
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

  def vanish
    placed_field = @field.select { |_, c| c =~ /[#{self.class::PUYO_OBJECTS}]/  }
    count = placed_field.count
    return if count == 0 

    marks = {}
    target_no = 0
    current_field_value = nil

    loop do
      diff = (placed_field.keys - marks.keys)
      break if diff.empty?

      # TODO: 
      # p diff

      # targets = placed_field.keys & marks.select { |_, v| v == target_no }.keys.map { |k| surrounding(k) }.flatten(1) - marks.keys
      # # targets = (marks.keys.map { |k| surrounding(k) }.flatten(1) - marks.keys)

      # if targets.empty?
      #   coord = diff.first
      #   marks[coord] = target_no
      #   target_no += 1
      #   current_field_value = placed_field[coord]
      #   targets = placed_field.keys & surrounding(coord) - marks.keys
      # end

      # targets.each do |coord|
      #   marks[coord] = target_no if current_field_value == placed_field[coord]
      # end
    end

    marks.group_by { |_, no| no }.each do |no, coords|
      if coords.size >= 4
        coords.each { |coord| @field[coord] = '_' }
      end
    end

    @field
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
end
