class FakeUI < UI
  attr_reader :output

  def initialize(game_wrapper, test, test_data, dice_roller)
    super(game_wrapper)

    @test         = test
    @test_data    = test_data
    @dice_roller  = dice_roller
    @output       = []
  end

  def end_of_player_turn_assertions
    @dice_roller.ensure_exact_use_of_dice

    actual_score   = @game_wrapper.score(@test_data.current_player)
    expected_score = @test_data.extract_score_and_advance_round

    @test.assert_equal expected_score, actual_score
  end

  def puts(output_string)
    @output << output_string
  end

  def ask_for_hold_positions(*)
    @test_data.next_hold_positions
  end

  def ask_for_category(*)
    @test_data.extract_category
  end
end
