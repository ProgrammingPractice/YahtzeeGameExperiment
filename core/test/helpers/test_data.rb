class TestData
  FILE_PATH = File.expand_path('../fixtures/complete_game.json', __dir__)

  attr_reader :player_turn_data
  attr_reader :winner_name
  attr_reader :winner_score

  def initialize
    json ||= JSON.parse(File.read(FILE_PATH))

    @players     = json.keys
    extract_winner(json)

    # TODO: use an object instead of array for turn_data
    player_turns = add_player_name_to_each_turn(json)
    @turns_iterator = merge_arrays(player_turns).each

    advance_to_next_player
  end

  private def add_player_name_to_each_turn(json)
    json.map do |player, turns|
      turns.map do |turn|
        turn << player
      end
    end
  end

  # Example:
  # [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  # => [1, 4, 7, 2, 5, 8, 3, 6, 9]
  private def merge_arrays(arrays)
    arrays[0].zip(*arrays[1..-1]).flatten(1)
  end

  def extract_winner(json)
    name_final_score_pairs = json.map do |player_name, player_turns|
      final_score = player_turns.last.last
      [player_name, final_score]
    end

    @winner_name, @winner_score = name_final_score_pairs.max { |a, b| a[1] <=> b[1] }
  end

  def current_player_name
    @player_turn_data.last
  end

  def player_names
    @players
  end

  def players_count
    @players.size
  end

  def turns_count
    @turns_iterator.size
  end

  def player_rolled_again?
    @last_hold_positions.size < 5
  end

  def advance_to_next_player
    @player_turn_data = @turns_iterator.next
    @hold_positions   = extract_hold_positions
  end

  def extract_category
    (roll0, hold0, roll1, hold1, roll2, category, score) = @player_turn_data
    category
  end

  def extract_dice
    (roll0, hold0, roll1, hold1, roll2, category, score) = @player_turn_data
    roll0 + roll1 + roll2
  end

  def next_hold_positions
    positions = @hold_positions.shift or unexpected_request_for_hold_positions
    @last_hold_positions = positions
    positions
  end

  private def unexpected_request_for_hold_positions
    raise <<~STRING
      TestData was asked for hold positions, but did not expect it.
        Player: #{current_player_name}
        Raw turn: #{@player_turn_data.inspect}
    STRING
  end

  private def extract_hold_positions
    (roll0, hold0, roll1, hold1, roll2, category, score) = @player_turn_data
    hold_positions0 = [0,1,2,3,4].select { |i| hold0[i] == 'x' }
    hold_positions1 = [0,1,2,3,4].select { |i| hold1[i] == 'x' } unless hold1.empty?
    [hold_positions0, hold_positions1]
  end

  def extract_score
    (roll0, hold0, roll1, hold1, roll2, category, score) = @player_turn_data
    score
  end
end
