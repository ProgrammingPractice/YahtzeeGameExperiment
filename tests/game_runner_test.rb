require_relative 'test_helper'
require 'json'

class GameRunnerTest < Minitest::Test
  class FakeUI
    attr_reader :current_round
    attr_reader :output

    def initialize(test, rounds, dice_roller)
      @test        = test
      @dice_roller = dice_roller
      @output      = []

      @rounds_iterators = rounds.each_with_object({}) do |(player, player_rounds), hash|
        hash[player] = player_rounds.each
      end
    end

    def run(game_wrapper)
      start_game_with_players(game_wrapper.players)

      while game_wrapper.rounds_left?
        game_wrapper.players.each do |player|
          play_round(player)
        end
      end

      display_winners(game_wrapper.winners)
    end

    def play_round(player)
      start_of_player_turn(player)

      player.roll_dice
      display_roll(player.roll)

      hold = ask_for_hold_positions
      player.reroll(positions_to_reroll(hold))
      display_roll(player.roll)

      if hold.size < 5
        hold = ask_for_hold_positions
        player.reroll(positions_to_reroll(hold))
        display_roll(player.roll)
      end

      category = ask_for_category
      player.select_category(category)

      end_of_player_turn(player)
    end

    def start_game_with_players(players)
      # nothing
    end

    def start_of_player_turn(player)
      @current_round = @rounds_iterators[player.name].next
      @dice_roller.add_values(extract_rolls(*@current_round))
      @hold_positions = extract_hold_positions(*@current_round)
    end

    def end_of_player_turn(player)
      unless @dice_roller.empty?
        raise "Too many dice values were provided in the round: #{@current_round.inspect}"
      end

      expected_score = extract_score(*@current_round)
      @test.assert_equal expected_score, player.score
    end

    def display_roll(roll)
      # nothing
    end

    def display_winners(players)
      @output << "#{players.map(&:name).join(' & ')} won with #{players.first.score} points!"
    end

    def ask_for_hold_positions
      @hold_positions.shift or raise "We were asked for hold positions, but did not expect it."
    end

    def ask_for_category
      extract_category(*@current_round)
    end

    private

    def positions_to_reroll(hold)
      [0, 1, 2, 3, 4] - hold
    end

    def extract_hold_positions(roll0, hold0, roll1, hold1, roll2, category, score)
      hold_positions0 = [0,1,2,3,4].select { |i| hold0[i] == 'x' }
      hold_positions1 = [0,1,2,3,4].select { |i| hold1[i] == 'x' } unless hold1.empty?
      [hold_positions0, hold_positions1]
    end

    def extract_category(roll0, hold0, roll1, hold1, roll2, category, score)
      category
    end

    def extract_score(roll0, hold0, roll1, hold1, roll2, category, score)
      score
    end

    def extract_rolls(roll0, hold0, roll1, hold1, roll2, category, score)
      roll0 + roll1 + roll2
    end
  end

  def test_complete_game
    json = JSON.load(File.read('tests/fixtures/complete_game.json'))
    rounds_p0 = json['rounds_p0']
    rounds_p1 = json['rounds_p1']

    dice_roller = FakeDiceRoller.new([])
    player0     = Player.new('Player 0', dice_roller)
    player1     = Player.new('Player 1', dice_roller)
    game        = Game.new([player0, player1])

    rounds = {
      player0.name => rounds_p0,
      player1.name => rounds_p1,
    }

    ui           = FakeUI.new(self, rounds, dice_roller)
    game_wrapper = GameWrapper.new(game)
    runner       = GameRunner.new(game_wrapper, ui)

    begin
      runner.run
    rescue FakeDiceRoller::OutOfValuesError
      raise "Not enough dice values were provided in the round: #{ui.current_round.inspect}"
    end
    assert_equal "Player 1 won with 75 points!", ui.output.last
  end
end