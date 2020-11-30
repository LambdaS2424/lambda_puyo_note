# frozen_string_literal: true

require 'lib/field'

class TsumoField < Field
  PUYO_OBJECTS = 'ABCD'

  def place(tsumo, move)
    oya, ko = tsumo.chars
    heights_tmp = heights

    if move.dir == Move::DOWN
      put_on_top(move.col, ko)
      put_on_top(move.col, oya)
    else
      put_on_top(move.col, oya)
      put_on_top(move.col + Move::RELATIVE_COL[move.dir], ko)
    end

    @field
  end
end
