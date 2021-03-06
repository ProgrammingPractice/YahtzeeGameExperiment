require 'remedy'

class UI
  KEY_ENTER = 'control_m'.freeze

  def initialize(game_wrapper)
    @game_wrapper = game_wrapper
  end

  def run
    loop do
      ui_action = @game_wrapper.next_step

      if ui_action.is_a?(GameWrapper::AskForHoldPositionsAction)
        input_from_user = ask_for_hold_positions(ui_action.roll, ui_action.player, ui_action.rolls_count, @game_wrapper.players)
      elsif ui_action.is_a?(GameWrapper::AskForCategoryAction)
        input_from_user = ask_for_category(ui_action.roll, ui_action.player, @game_wrapper.players)
      else
        raise "Unknown action: #{ui_action.inspect}"
      end

      @game_wrapper.advance(input_from_user)

      end_of_step_hook

      break if @game_wrapper.game_finished?
    end

    display_winners(@game_wrapper.winners)
  end

  def end_of_step_hook
    if @game_wrapper.player_turn_finished?
      @game_wrapper.advance_to_next_player

      end_of_player_turn_assertions
    end
  end

  def end_of_player_turn_assertions; end

  def self.ask_for_number_of_players
    new(nil).ask_for_number_of_players
  end

  def ask_for_number_of_players
    players_count = 1

    display = -> { display_players_count(players_count) }
    commands = {
      'up'   => -> { players_count += 1 },
      'down' => -> { players_count = [1, players_count - 1].max }
    }

    interaction_loop(display, commands)

    players_count
  end

  def ask_for_hold_positions(roll, player, rolls_count, players)
    cursor       = 0
    hold_pattern = [1,1,1,1,1]

    display = -> { display_hold(roll, cursor, hold_pattern, player, rolls_count, players) }
    commands = {
      'right' => -> { cursor = (cursor + 1) % 5 },
      'left'  => -> { cursor = (cursor - 1) % 5 },
      'space' => -> { hold_pattern[cursor] = (hold_pattern[cursor] + 1) % 2 },
    }

    interaction_loop(display, commands)

    (0..4).select { |i| hold_pattern[i] == 1 }
  end

  def ask_for_category(roll, player, players)
    index = 0

    display = -> { display_categories(index, roll, players, player) }
    commands = {
      'down' => -> { index = (index + 1) % categories(player).size },
      'up'   => -> { index = (index - 1) % categories(player).size }
    }

    interaction_loop(display, commands)

    categories(player)[index]
  end

  def display_winners(winners)
    print_message "#{winners.map(&:name).join(' & ')} won with #{winners.first.score} points!"
  end

  def print_message(message)
    puts(message)
  end

  private

  def interaction_loop(display, commands)
    display.call

    Remedy::Keyboard.raise_on_control_c!
    loop do
      key = Remedy::Keyboard.get.to_s

      if key == 'q'
        print_message 'Bye'
        exit
      elsif key == KEY_ENTER
        break
      elsif commands.key?(key)
        commands.fetch(key).call
      end

      display.call
    end
  end

  def display_players_count(players_count)
    header = Remedy::Header.new(["Yahtzee!\nSelect number of players"])
    footer = Remedy::Footer.new(["--------\nUse up/down to change values. Enter to accept."])

    Remedy::Viewport.new.draw(Remedy::Content.new([players_count.to_s]), Remedy::Size.new(0,0), header, footer)
    Remedy::ANSI.cursor.home!
    Remedy::ANSI.push(Remedy::ANSI.cursor.down(2))
  end

  def display_hold(roll, cursor, hold_pattern, player, rolls_count, players)
    dice_to_hold = hold_pattern.each_with_index.map do |value, i|
      value == 0 ? '-' : roll[i]
    end.join

    message = "
      You rolled: #{roll.inspect} (roll #{rolls_count}/3)
      Select what to hold:
      #{dice_to_hold}
      --------
      Available categories:
      #{category_names(player).join("\n")}
    ".gsub(/^\s+/, '')

    footer = Remedy::Footer.new(["--------\nUse left/right to move around. Space to mark position. Enter to accept."])

    Remedy::Viewport.new.draw(Remedy::Content.new([message]), Remedy::Size.new(0,0), header(player, players), footer)
    Remedy::ANSI.cursor.home!
    Remedy::ANSI.push(Remedy::ANSI.cursor.down(players.size + 4))
    Remedy::ANSI.push(Remedy::ANSI.cursor.to_column(cursor + 1))
  end

  def display_categories(index, roll, players, player)
    message = "Please select category for roll: #{roll.inspect}
      #{category_names(player).join("\n")}
    ".gsub(/^\s+/, '')

    footer = Remedy::Footer.new(["--------\nUse up/down to move around. Enter to accept."])

    Remedy::Viewport.new.draw(Remedy::Content.new([message]), Remedy::Size.new(0,0), header(player, players), footer)
    Remedy::ANSI.cursor.home!
    Remedy::ANSI.push(Remedy::ANSI.cursor.down(players.size + index + 3))
  end

  def header(player, players)
    message = players.map do |player|
      "#{player.name}: #{player.score} points"
    end.join("\n")

    Remedy::Header.new([message, '--------', "Playing -> #{player.name}"])
  end

  def categories(player)
    player.categories
  end

  def category_names(player)
    categories(player).map do |category|
      category.gsub(/_/, " ").capitalize
    end
  end
end
