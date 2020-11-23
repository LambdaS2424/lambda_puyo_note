# frozen_string_literal: true

class TsumoState
  # N 手までの理論全パタン
  def self.all_patterns(depth)
    tree = Node.new(
      state: State::ABCD,
      child_ids: [] 
    )

    leaves = [tree]

    depth.times do
      nodes = leaves
      leaves = []
      nodes.each do |node|
        node[:state].routes.each do |tsumo, state|
          next_node = Node.new(
            tsumo: tsumo,
            state: state,
            parent: node,
            child_ids: []
          )
          node[:child_ids] << next_node.id
          leaves << next_node
        end
      end
    end

    [leaves, tree]
  end

  # N 手までの実ツモを木構造で表現する
  def self.make_tree(sequences, depth: 5)
    root = Node.new(
      state: State::ABCD,
      child_ids: [],
      sequence_ids: sequences.pluck(:id)
    )

    leaves = []
    nodes = {}

    nodes[''] = root

    sequences.each_slice(1024).each do |secs|
      puts(format("%<id> 6d\e[1F", id: secs.first.id))
      secs.each do |sequence|
        pattern = sequence.sorted_pattern[0..(2 * depth)-1]
        current_node = root
        pattern.chars.each_slice(2).map(&:join).each do |tsumo|
          parent = current_node
          node = nodes[parent.id + tsumo]
          node ||= Node.new(
            tsumo: tsumo,
            state: current_node[:state].next_state(tsumo),
            parent: parent,
            child_ids: [],
            sequence_ids: []
          )
          node[:sequence_ids] << sequence.id
          parent[:child_ids] << node.id
          current_node = node
          nodes[node.id] = node
        end

        current_node[:sequence_id] = sequence.id

        leaves << current_node
      end
    end

    puts "\e[1E"

    [root, leaves, nodes]
  end

  def initialize(color_sequence)
    @current_state = State::ABCD
    @color_sequence = color_sequence
  end

  def color_map
    @color_sequence.sequence.each do |tsumo_color|
      @current_state = move_next_by_color_pair(tsumo_color, @current_state)
      break if map.fixed?
    end

    return nil unless map.fixed?

    map.to_color_map
  end

  def map
    @map ||= ColorPatternMap.new(@color_sequence)
  end

  private

  def move_next_by_color_pair(pair, current_state = @current_state)
    # puts("[#{current_state}] map=#{map.to_h}, pair=#{pair.to_h}")
    # binding.pry if map[Puyo::Pattern::B].empty?

    case current_state
    when State::ABCD
      if pair.oya == pair.ko
        # AA
        map.fix(Puyo::Pattern::A, pair.oya)
        State::BCD
      else
        # AB
        map[Puyo::Pattern::A] = [pair.oya, pair.ko]
        map[Puyo::Pattern::B] = [pair.oya, pair.ko]
        map[Puyo::Pattern::C].delete(pair.oya)
        map[Puyo::Pattern::C].delete(pair.ko)
        map[Puyo::Pattern::D].delete(pair.oya)
        map[Puyo::Pattern::D].delete(pair.ko)
        State::AB_CD
      end

    when State::BCD
      if [pair.oya] == map[Puyo::Pattern::A] && pair.oya == pair.ko
        # AA
        State::BCD
      elsif [pair.oya] == map[Puyo::Pattern::A]
        # AB
        map.fix(Puyo::Pattern::B, pair.ko)
        State::CD
      elsif [pair.ko] == map[Puyo::Pattern::A]
        # AB
        map.fix(Puyo::Pattern::B, pair.oya)
        State::CD
      elsif pair.oya == pair.ko
        # BB
        map.fix(Puyo::Pattern::B, pair.oya)
        State::CD
      else
        # BC
        map[Puyo::Pattern::B] = [pair.oya, pair.ko]
        map[Puyo::Pattern::C] = [pair.oya, pair.ko]
        map[Puyo::Pattern::D].delete(pair.oya)
        map[Puyo::Pattern::D].delete(pair.ko)
        State::BC
      end

    when State::AB_CD
      if map[Puyo::Pattern::A].include?(pair.oya) && pair.oya == pair.ko
        # AA
        map.fix(Puyo::Pattern::A, pair.oya)
        State::CD
      elsif map[Puyo::Pattern::A].include?(pair.oya) && map[Puyo::Pattern::B].include?(pair.ko)
        # AB
        State::AB_CD
      elsif map[Puyo::Pattern::A].include?(pair.ko) && map[Puyo::Pattern::B].include?(pair.oya)
        # AB
        State::AB_CD
      elsif map[Puyo::Pattern::A].include?(pair.oya) && map[Puyo::Pattern::C].include?(pair.ko)
        # AC
        map.fix(Puyo::Pattern::A, pair.oya)
        map.fix(Puyo::Pattern::C, pair.ko)
        State::FREE
      elsif map[Puyo::Pattern::A].include?(pair.ko) && map[Puyo::Pattern::C].include?(pair.oya)
        # AC
        map.fix(Puyo::Pattern::A, pair.ko)
        map.fix(Puyo::Pattern::C, pair.oya)
        State::FREE
      elsif map[Puyo::Pattern::C].include?(pair.oya) && pair.oya == pair.ko
        # CC
        map.fix(Puyo::Pattern::C, pair.oya)
        State::AB
      else
        # CD
        State::AB_CD
      end

    when State::AB      
      if map[Puyo::Pattern::A].include?(pair.oya) && pair.oya == pair.ko
        # AA
        map.fix(Puyo::Pattern::A, pair.oya)
        State::CD
      elsif map[Puyo::Pattern::A].include?(pair.oya) && map[Puyo::Pattern::B].include?(pair.ko)
        # AB
        State::AB
      elsif map[Puyo::Pattern::A].include?(pair.ko) && map[Puyo::Pattern::B].include?(pair.oya)
        # AB
        State::AB
      elsif map[Puyo::Pattern::A].include?(pair.oya) && map[Puyo::Pattern::C].include?(pair.ko)
        # AC
        map.fix(Puyo::Pattern::A, pair.oya)
        map.fix(Puyo::Pattern::C, pair.ko)
        State::FREE
      elsif map[Puyo::Pattern::A].include?(pair.ko) && map[Puyo::Pattern::C].include?(pair.oya)
        # AC
        map.fix(Puyo::Pattern::A, pair.ko)
        map.fix(Puyo::Pattern::C, pair.oya)
        State::FREE
      elsif map[Puyo::Pattern::A].include?(pair.oya) && map[Puyo::Pattern::D].include?(pair.ko)
        # AD
        map.fix(Puyo::Pattern::A, pair.oya)
        State::FREE
      elsif map[Puyo::Pattern::A].include?(pair.ko) && map[Puyo::Pattern::D].include?(pair.oya)
        # AD
        map.fix(Puyo::Pattern::A, pair.ko)
        State::FREE
      else
        # CC
        # CD
        # DD
        State::AB
      end

    when State::BC
      if map[Puyo::Pattern::A].include?(pair.oya) && pair.oya == pair.ko
        # AA
        State::BC
      elsif map[Puyo::Pattern::A].include?(pair.oya) && map[Puyo::Pattern::B].include?(pair.ko)
        # AB
        map.fix(Puyo::Pattern::B, pair.ko)
        State::FREE
      elsif map[Puyo::Pattern::A].include?(pair.ko) && map[Puyo::Pattern::B].include?(pair.oya)
        # AB
        map.fix(Puyo::Pattern::B, pair.oya)
        State::FREE
      elsif map[Puyo::Pattern::A].include?(pair.oya) && map[Puyo::Pattern::D].include?(pair.ko)
        # AD
        State::BC
      elsif map[Puyo::Pattern::A].include?(pair.ko) && map[Puyo::Pattern::D].include?(pair.oya)
        # AD
        State::BC
      elsif map[Puyo::Pattern::B].include?(pair.oya) && pair.oya == pair.ko
        # BB
        map.fix(Puyo::Pattern::B, pair.ko)
        State::FREE
      elsif map[Puyo::Pattern::B].include?(pair.oya) && map[Puyo::Pattern::B].include?(pair.ko)
        # BC
        State::BC
      elsif map[Puyo::Pattern::B].include?(pair.oya) && map[Puyo::Pattern::D].include?(pair.ko)
        # BD
        map.fix(Puyo::Pattern::B, pair.oya)
        State::FREE
      elsif map[Puyo::Pattern::B].include?(pair.ko) && map[Puyo::Pattern::D].include?(pair.oya)
        # BD
        map.fix(Puyo::Pattern::B, pair.ko)
        State::FREE
      elsif map[Puyo::Pattern::D].include?(pair.oya) && pair.oya == pair.ko
        # DD
        State::BC
      end

    when State::CD
      if map[Puyo::Pattern::A].include?(pair.oya) && pair.oya == pair.ko
        # AA
        State::CD
      elsif map[Puyo::Pattern::A].include?(pair.oya) && map[Puyo::Pattern::B].include?(pair.ko)
        # AB
        State::CD
      elsif map[Puyo::Pattern::A].include?(pair.ko) && map[Puyo::Pattern::B].include?(pair.oya)
        # AB
        State::CD
      elsif map[Puyo::Pattern::A].include?(pair.oya) && map[Puyo::Pattern::C].include?(pair.ko)
        # AC
        map.fix(Puyo::Pattern::C, pair.ko)
        State::FREE
      elsif map[Puyo::Pattern::A].include?(pair.ko) && map[Puyo::Pattern::C].include?(pair.oya)
        # AC
        map.fix(Puyo::Pattern::C, pair.oya)
        State::FREE
      elsif map[Puyo::Pattern::B].include?(pair.oya) && pair.oya == pair.ko
        # BB
        State::CD
      elsif map[Puyo::Pattern::B].include?(pair.oya) && map[Puyo::Pattern::C].include?(pair.ko)
        # BC
        map.fix(Puyo::Pattern::C, pair.ko)
        State::FREE
      elsif map[Puyo::Pattern::B].include?(pair.ko) && map[Puyo::Pattern::C].include?(pair.oya)
        # BC
        map.fix(Puyo::Pattern::C, pair.oya)
        State::FREE
      elsif map[Puyo::Pattern::C].include?(pair.oya) && pair.oya == pair.ko
        # CC
        map.fix(Puyo::Pattern::C, pair.oya)
        State::FREE
      else
        # CD
        State::CD
      end

    when State::FREE
      State::FREE
    end
  end

  def next_state(tsumo, current_state = @current_state)
    case current_state
    when State::ABCD
      case tsumo
      when Tsumo::AA then State::BCD
      when Tsumo::AB then State::AB_CD
      end

    when State::BCD
      case tsumo
      when Tsumo::AA then State::BCD
      when Tsumo::AB then State::CD
      when Tsumo::BB then State::CD
      when Tsumo::BC then State::BC
      end

    when State::AB_CD
      case tsumo
      when Tsumo::AA then State::CD
      when Tsumo::AB then State::AB_CD
      when Tsumo::AC then State::FREE
      when Tsumo::CC then State::AB
      when Tsumo::CD then State::AB_CD
      end

    when State::AB
      case tsumo
      when Tsumo::AA then State::FREE
      when Tsumo::AB then State::AB
      when Tsumo::AC then State::FREE
      when Tsumo::AD then State::FREE
      when Tsumo::CC then State::AB
      when Tsumo::CD then State::AB
      when Tsumo::DD then State::AB
      end

    when State::BC
      case tsumo
      when Tsumo::AA then State::BC
      when Tsumo::AB then State::FREE
      when Tsumo::AD then State::BC
      when Tsumo::BB then State::FREE
      when Tsumo::BC then State::BC
      when Tsumo::BD then State::FREE
      when Tsumo::DD then State::BC
      end

    when State::CD
      case tsumo
      when Tsumo::AA then State::CD
      when Tsumo::AB then State::CD
      when Tsumo::AC then State::FREE
      when Tsumo::BB then State::CD
      when Tsumo::BC then State::FREE
      when Tsumo::CC then State::FREE
      when Tsumo::CD then State::CD
      end

    when State::FREE
      State::FREE
    end
  end
end
