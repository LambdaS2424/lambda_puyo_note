# frozen_string_literal: true

class Shape
  attr_reader :field
  attr_reader :errors

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
end
