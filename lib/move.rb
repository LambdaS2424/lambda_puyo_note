# frozen_string_literal: true

module Move
  UP = 'U'
  RIGHT = 'R'
  DOWN = 'D'
  LEFT = 'L'
  RELATIVE_COL = {
    UP => 0,
    RIGHT => 1,
    DOWN => 0,
    LEFT => -1
  }

  class M_
    attr_reader :column, :direction
    alias :col :column
    alias :dir :direction

    def initialize(column, direction)
      @column = column
      @direction = direction
      @exempt_when_zoro = [DOWN, LEFT].include?(direction)
    end

    def col_index
      @column - 1
    end

    def exempt_when_zoro?
      @exempt_when_zoro
    end

    # この move で置かれるぷよの位置を配列で返す (列の index は 0 始まり)
    #
    # e.g.)
    # 1 列に二つぷよが置かれる場合: [0, 0]
    # 2, 3 列にぷよが置かれる場合: [1, 2]
    def occupations
      [@column - 1, @column - 1 + RELATIVE_COL[@direction]]
    end

    def to_s
      "#{@column}#{@direction}"
    end
  end
  
  COL_1_DIR_U = M_.new(1, UP)
  COL_1_DIR_R = M_.new(1, RIGHT)
  COL_1_DIR_D = M_.new(1, DOWN)
  COL_2_DIR_U = M_.new(2, UP)
  COL_2_DIR_R = M_.new(2, RIGHT)
  COL_2_DIR_D = M_.new(2, DOWN)
  COL_2_DIR_L = M_.new(2, LEFT)
  COL_3_DIR_U = M_.new(3, UP)
  COL_3_DIR_R = M_.new(3, RIGHT)
  COL_3_DIR_D = M_.new(3, DOWN)
  COL_3_DIR_L = M_.new(3, LEFT)
  COL_4_DIR_U = M_.new(4, UP)
  COL_4_DIR_R = M_.new(4, RIGHT)
  COL_4_DIR_D = M_.new(4, DOWN)
  COL_4_DIR_L = M_.new(4, LEFT)
  COL_5_DIR_U = M_.new(5, UP)
  COL_5_DIR_R = M_.new(5, RIGHT)
  COL_5_DIR_D = M_.new(5, DOWN)
  COL_5_DIR_L = M_.new(5, LEFT)
  COL_6_DIR_U = M_.new(6, UP)
  COL_6_DIR_D = M_.new(6, DOWN)
  COL_6_DIR_L = M_.new(6, LEFT)

  ALL = [
    # col, direction
    COL_1_DIR_U,
    COL_1_DIR_R,
    COL_1_DIR_D,
    COL_2_DIR_U,
    COL_2_DIR_R,
    COL_2_DIR_D,
    COL_2_DIR_L,
    COL_3_DIR_U,
    COL_3_DIR_R,
    COL_3_DIR_D,
    COL_3_DIR_L,
    COL_4_DIR_U,
    COL_4_DIR_R,
    COL_4_DIR_D,
    COL_4_DIR_L,
    COL_5_DIR_U,
    COL_5_DIR_R,
    COL_5_DIR_D,
    COL_5_DIR_L,
    COL_6_DIR_U,
    COL_6_DIR_D,
    COL_6_DIR_L,
  ].freeze

  ALL_FOR_DOUBLE = [
    COL_1_DIR_U,
    COL_1_DIR_R,
    COL_2_DIR_U,
    COL_2_DIR_R,
    COL_3_DIR_U,
    COL_3_DIR_R,
    COL_4_DIR_U,
    COL_4_DIR_R,
    COL_5_DIR_U,
    COL_5_DIR_R,
    COL_6_DIR_U
  ].freeze

  CHIGIRI_EXCLUSINO_MAP = [
    # 1-2 列間の段差がある場合に除外される置き方
    [
      COL_1_DIR_R,
      COL_2_DIR_L
    ],
    
    # 2-3 列間の段差がある場合に除外される置き方
    [
      COL_2_DIR_R,
      COL_3_DIR_L
    ],

    # 3-4 列間の段差がある場合に除外される置き方
    [
      COL_3_DIR_R,
      COL_4_DIR_L
    ],

    # 4-5 列間の段差がある場合に除外される置き方
    [
      COL_4_DIR_R,
      COL_5_DIR_L
    ],

    # 5-6 列間の段差がある場合に除外される置き方
    [
      COL_5_DIR_R,
      COL_6_DIR_L
    ]
  ].freeze

  def self.all(no_chigiri: false, heights: Array.new(6, 0), for_double: false)
    moves = for_double ? ALL_FOR_DOUBLE : ALL

    return moves unless no_chigiri

    exclusions = heights.each_cons(2).each_with_object([]).with_index do |((a, b), arr), index|
      a != b && arr.concat(CHIGIRI_EXCLUSINO_MAP[index])
    end

    moves - exclusions
  end
end
