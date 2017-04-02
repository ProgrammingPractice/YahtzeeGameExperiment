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
      while game_wrapper.rounds_left?
        game_wrapper.players.each do |player|
          start_of_player_turn(player)
          play_round(game_wrapper, player)
          end_of_player_turn(player)
        end
      end

      display_winners(game_wrapper.winners)
    end

    def play_round(game_wrapper, player)
      result = nil
      game_wrapper.each_step(player) do |step|
        ui_action         = step[0]
        game_wrapper_code = step[1]

        result = send(ui_action)
        game_wrapper_code.call(result)
      end
    end

    def ask_for_nothing
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
    json = JSON.parse(File.read('tests/fixtures/complete_game.json'))
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

    begin
      ui.run(game_wrapper)
    rescue FakeDiceRoller::OutOfValuesError
      raise "Not enough dice values were provided in the round: #{ui.current_round.inspect}"
    end
    assert_equal "Player 1 won with 75 points!", ui.output.last
  end
end
