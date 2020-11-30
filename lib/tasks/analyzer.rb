# frozen_string_literal: true

module Tasks
  class Analyzer < Thor
    include Thor::Actions

    desc 'debug', 'debug'
    def debug
      db_connection do
        # shape_field = ShapeField.load(file: 'resources/shape_fields/field001.shp')
        tsumo_field = TsumoField.load(file: 'resources/tsumo_fields/field001.shp')
        # ret = shape_field.match?(tsumo_field)
        # tsumo_field.place('DD', Move::COL_1_DIR_U)
binding.pry
        zenkeshi_sequences = Sequence.zenkeshi(6, 3)
        sequence = zenkeshi_sequences.first

        tsumo_field = TsumoField.new

        move_pats = MoveState.all_patterns(5, no_chigiri: true, for_pattern: sequence.sorted_pattern)

        leaves = move_pats.last[1]
        leaves[100..-1].each do |leave|
          moves = leave.to_pattern
          tsumos = sequence.sorted_pattern.chars.each_slice(2).map(&:join)
          moves.each_with_index do |move, index|
            tsumo_field.place(tsumos[index], move)
          end
          puts tsumo_field

          binding.pry
          break
        end
        # sequences = TsumoPattern.zenkeshi(6, 3)

        #binding.pry
      end
    end

    desc 'move_patterns', 'N手 の配置パタン数'
    def move_patterns(depth = 5)
      depth = depth.to_i

      db_connection do
        result = MoveState.all_patterns(depth, no_chigiri: true)

        result_for_print = result.map { |(d, _, count)| [d, 22 ** d, count] }
        result_for_print = result_for_print.unshift(%w[N all no_chigiri])
        print_table(result_for_print)
      end
    end

    desc 'pattern_group', 'N手 までにツモパタンが確定するパタン数'
    def pattern_group(depth = 13)
      depth = depth.to_i
      db_connection do
        result = (1..depth).map { |depth| sequences.map(&:sorted_pattern).group_by { |pat| pat[0..(2 * depth) - 1] }.select { |k, v| v.size == 1 }.count }
        result_for_print = (1..depth).to_a.zip(result).map { |v| v + [to_percent(v[1].to_f / all_count)] }.unshift(%w[N patterns percent])
        print_table(result_for_print)
      end
    end

    desc 'make_tree', 'N 手までの実ツモ（65536パタンのツモ）を木構造で表現する'
    def make_tree
      db_connection do
        root, leaves, nodes = TsumoState.make_tree(sequences, depth: 10)
      end
    end

    desc 'zenkeshi_patterns <N> <C>', 'N 手までの色数が C 以下、かつ各色のぷよ数 4 以上である sequence の一覧'
    def zenkeshi_patterns(depth = 10)
      depth = depth.to_i

      db_connection do
        result = {
          part: {},
          full: {}
        }

        loops = (2..depth).map { |n| (1..4).map { |c| [n, c] }}.flatten(1).each do |(n, colors)|
          ret = sequences.map(&:sorted_pattern).select do |pattern|
            group = pattern[0..(2 * n) - 1].chars.group_by(&:itself)
            group.values.all? { |v| v.size >= 4 } && group.keys.count == colors
          end
          say("### #{n}-#{colors} (#{ret.count} / #{all_count})")
          result[:full][[n, colors]] = ret.sort
          result[:part][[n, colors]] = ret.map { |pat| pat[0..(2 * n) - 1] }.sort.uniq
        end

        result_for_print = result[:full].map do |(n, colors), sequences|
          count = Kernel.format('%<count> 6d', count: sequences.count)
          [n, colors, count, to_percent(count.to_f / all_count)]
        end
        result_for_print.unshift(%w[N Colors count portion])
        print_table(result_for_print)
        
        binding.pry
        result
      end
    end

    desc 'show_pattern_lacks', '出現しないツモ順の数を計算する'
    def show_pattern_lacks(depth = 8)
      db_connection do
        result = []
        result << %w[N theory actual lack]
        (1..depth).each do |depth|
          # say_status(:depth, depth)
          actual = dist(depth).map(&:second)
          theory, _ = TsumoState.all_patterns(depth)
          theory = theory.map { |node| node.to_pattern[0..(2 * depth) - 1] }

          # say("theory.count=#{theory.count}, actual.count=#{actual.count} (theory - actual).count = #{(theory - actual).count}, (actual - theory).count=#{(actual - theory).count}")
          result << [depth, theory.count, actual.count, (theory - actual).count]
          # binding.pry if (theory - actual).any? { |pat| !pat.start_with?('ABCD') }
        end

        print_table(result)
      end
    end

    desc 'distribution', 'N手 パタンの場合の数'
    option :start_with, type: :string, default: nil
    def distribution(depth)
      db_connection do
        result = dist(depth.to_i)
        print_table(result)
      end
    end

    desc 'possible_patterns', 'N 手までの全パタン'
    def possible_patterns(depth)
      db_connection do
        leaves, tree = TsumoState.all_patterns(depth.to_i)
        binding.pry
      end
    end

    no_commands do
      def sequences
        @sequences ||= Sequence.all
      end

      def all_count
        @all_count ||= sequences.count
      end

      def dist(depth = 2)
        index_overhead = options[:start_with]&.length || 0

        range = index_overhead..(depth * 2 + index_overhead - 1)

        result = []
        patterns = sequences.map(&:sorted_pattern)
        patterns = patterns.select { |pat| pat.start_with?(options[:start_with]) } if options[:start_with]
        group_count = patterns.map { |pat| pat[range] }.group_by(&:itself)
        count = group_count.map { |gc| gc[1].size }.sum
        group_count.each do |k, v|
          result << [
            options[:start_with],
            k,
            v.size,
            to_percent(v.size.to_f / all_count),
            to_percent(v.size.to_f / count),
          ]
        end
        result.sort_by { |arr| arr[1] }
      end

      def to_percent(value, precision: 1)
        v = (value * 100).floor(precision)
        format('%<value>5.1f %%', value: v)
      end
    end
  end
end
