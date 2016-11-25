require_relative 'test_helper'
require_relative '../lib/player'

class IntegrationTest < Minitest::Test
  def test_integration_between_player_and_dice_roller
    player = Player.new('P1', DiceRoller.new)
    assert 5, player.roll_dice.size
  end
end
