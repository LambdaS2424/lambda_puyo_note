# frozen_string_literal: true

require 'forwardable'

module Tasks
  class Analyzer < Thor
    include Thor::Actions

    desc 'make_tree', 'N 手までの実ツモを木構造で表現する'
    def make_tree
      db_connection do
        root, leaves, nodes = TsumoState.make_tree(sequences, depth: 10)
      end
    end

    desc 'zenkeshi_patterns <N> <C>', 'N 手までの色数が C 以下、かつ各色のぷよ数 4 以上である sequence の一覧'
    def zenkeshi_patterns
      db_connection do
        result = {
          part: {},
          full: {}
        }

        loops = (2..10).map { |n| (1..4).map { |c| [n, c] }}.flatten(1).each do |(n, colors)|
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
    def show_pattern_lacks
      db_connection do
        (2..8).each do |depth|
          say_status(:depth, depth)
          actual = dist(depth).map(&:second)
          theory, _ = TsumoState.all_patterns(depth)
          theory = theory.map(&:to_sequence)

          say("theory.count=#{theory.count}, actual.count=#{actual.count} (theory - actual).count = #{(theory - actual).count}, (actual - theory).count=#{(actual - theory).count}")
          binding.pry if (theory - actual).any? { |pat| !pat.start_with?('ABCD') }
        end
      end
    end

    desc 'distribution', 'N手の角パタンの場合の数'
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
