# frozen_string_literal: true

class ScoreCalculator
  # 連鎖ボーナス　
  CHAIN_BONUS = [0, 0, 8, 16, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, 480, 512].freeze

  # 連結ボーナス
  # 11連結以上の場合にデフォルト値を使用するため Hash で表現
  LINK_BONUS = Hash.new(10)
                 .tap { |h| h.merge!(0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0).merge!(Hash[(5..10).map { |c| [c, c - 3]}]) }
                 .freeze

  # 色数ボーナス
  COLOR_BONUS = [0, 0, 3, 6, 12, 24].freeze

  # ぷよの消えた数×10（連鎖ボーナス＋連結ボーナス＋色数ボーナス）
  #
  # === Parameters
  # - stats [Array[Hash]] e.g.) [{"B"=>[4, 6], "C"=>[5]}, {"A"=>[4]}, {"C"=>[4]}, {"A"=>[4]}, {"B"=>[4]}]
  def self.calc_stats(stats)
    stats.map.with_index do |stat, i|
      calc_stat(i + 1, stat)
    end.sum
  end

  # 一連差分（一回の同時消去分）の点数を計算する
  #
  # === Parameters
  # - chain [Integer] 連鎖数
  # - stats [Hash] e.g.) {"B"=>[4, 6], "C"=>[5]}
  def self.calc_stat(chain, stat)
    vanished_num = 0
    bonus = [
      # 連鎖ボーナス
      CHAIN_BONUS[chain],

      # 連結ボーナス
      link_bonus = stat.map do |color, links|
        links.map do |num|
          vanished_num += num
          LINK_BONUS[num]
        end.sum
      end.sum,

      # 色数ボーナス
      COLOR_BONUS[stat.count]
    ].sum

    vanished_num * 10 * (bonus.zero? ? 1 : bonus)
  end
end
