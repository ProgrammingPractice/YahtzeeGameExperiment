require_relative 'player'

class Game
  attr_reader :players

  def initialize(count)
    @players = (1..count).map { Player.new }
  end

  def rounds_left?
    !@players.first.categories.empty?
  end
end
