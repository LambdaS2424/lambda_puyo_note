# frozen_string_literal: true

require 'lib/tsumo'

class State
  attr_accessor :routes

  def initialize(name)
    @name = name
    @routes = {}
  end

  def next_state(tsumo)
    @routes[tsumo]
  end

  # ABCD = 'A=B=C=D'
  # BCD = 'B=C=D'
  # AB = 'A=B'
  # BC = 'B=C'
  # CD = 'C=D'
  # AB_CD = 'A=B,C=D'
  # FREE = 'FREE'
  ABCD = self.new('A=B=C=D')
  BCD = self.new('B=C=D')
  AB_CD = self.new('A=B,C=D')
  AB = self.new('A=B')
  BC = self.new('B=C')
  CD = self.new('C=D')
  FREE = self.new('FREE')

  ABCD.routes = {
    Tsumo::AA => State::BCD,
    Tsumo::AB => State::AB_CD
  }

  BCD.routes = {
    Tsumo::AA => State::BCD,
    Tsumo::AB => State::CD,
    Tsumo::BB => State::CD,
    Tsumo::BC => State::BC
  }

  AB_CD.routes = {
    Tsumo::AA => State::CD,
    Tsumo::AB => State::AB_CD,
    Tsumo::AC => State::FREE,
    Tsumo::CC => State::AB,
    Tsumo::CD => State::AB_CD
  }

  AB.routes = {
    Tsumo::AA => State::FREE,
    Tsumo::AB => State::AB,
    Tsumo::AC => State::FREE,
    Tsumo::AD => State::FREE,
    Tsumo::CC => State::AB,
    Tsumo::CD => State::AB,
    Tsumo::DD => State::AB
  }

  BC.routes = {
    Tsumo::AA => State::BC,
    Tsumo::AB => State::FREE,
    Tsumo::AD => State::BC,
    Tsumo::BB => State::FREE,
    Tsumo::BC => State::BC,
    Tsumo::BD => State::FREE,
    Tsumo::DD => State::BC
  }

  CD.routes = {
    Tsumo::AA => State::CD,
    Tsumo::AB => State::CD,
    Tsumo::AC => State::FREE,
    Tsumo::BB => State::CD,
    Tsumo::BC => State::FREE,
    Tsumo::CC => State::FREE,
    Tsumo::CD => State::CD
  }

  FREE.routes = {
    Tsumo::AA => State::FREE,
    Tsumo::AB => State::FREE,
    Tsumo::AC => State::FREE,
    Tsumo::AD => State::FREE,
    Tsumo::BB => State::FREE,
    Tsumo::BC => State::FREE,
    Tsumo::BD => State::FREE,
    Tsumo::CC => State::FREE,
    Tsumo::CD => State::FREE,
    Tsumo::DD => State::FREE
  }
end
