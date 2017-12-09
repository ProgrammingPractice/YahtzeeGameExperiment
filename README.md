# YahtzeeGame

Full implementation of the Yahtzee game. Developed using pair programming and TDD.

We implemented 2 versions of the game: console and web.

To run the console version, run this in the command line:

        bundle exec ruby yahtzee.rb

For the web version you can find instructions in 'web/README.md'

## Console version

- Running tests

        bin/run_tests

## Naming convention

- round: the game has 15 rounds. One round lasts for all players
- player_turn: the player's part in a round
- step: any of the steps in a player turn
    - step_roll_0
    - step_hold_0
    - step_roll_1 (optional)
    - step_hold_1 (optional)
    - step_roll_2 (optional)
    - step_select_category

## Game rules

The game of yahtzee is a simple dice game. Each player
rolls five six-sided dice. They can re-roll some or all
of the dice up to three times (including the original roll).

For example, suppose a players rolls
    3,4,5,5,2
They hold (-,-,5,5,-) and re-roll (3,4,-,-,2)
    5,1,5,5,3
They hold (5,-,5,5,-) and re-roll (-,1,-,-,3)
    5,6,5,5,2

The player then places the roll in a category, such as ones,
twos, fives, pair, two pairs etc (see below). If the roll is
compatible with the category, the player gets a score for the
roll according to the rules. If the roll is not compatible
with the category, the player scores zero for the roll.

For example, suppose a player scores 5,6,5,5,2 in the fives
category they would score 15 (three fives). The score for
that go is then added to their total and the category cannot
be used again in the remaining goes for that game.
A full game consists of one go for each category. Thus, for
their last go in a game, a player must choose their only
remaining category.

### Categories list

_Note these rules differ from the original (copyrighted) rules_

Chance:
  The player scores the sum of all dice,
  no matter what they read.
  For example,
   1,1,3,3,6 placed on "chance" scores 14 (1+1+3+3+6)
   4,5,5,6,1 placed on "chance" scores 21 (4+5+5+6+1)

Yahtzee:
  If all dice have the same number,
  the player scores 50 points.
    For example,
   1,1,1,1,1 placed on "yahtzee" scores 50
   1,1,1,2,1 placed on "yahtzee" scores 0

Ones, Twos, Threes, Fours, Fives, Sixes:
  The player scores the sum of the dice that reads one,
    two, three, four, five or six, respectively.
    For example,
   1,1,2,4,4 placed on "fours" scores 8 (4+4)
   2,3,2,5,1 placed on "twos" scores 4  (2+2)
   3,3,3,4,5 placed on "ones" scores 0

Pair:
  The player scores the sum of the two highest matching dice.
  For example, when placed on "pair"
     3,3,3,4,4 scores 8 (4+4)
   1,1,6,2,6 scores 12 (6+6)
   3,3,3,4,1 scores 0
   3,3,3,3,1 scores 0

Two pairs:
  If there are two pairs of dice with the same number, the
  player scores the sum of these dice.
    For example, when placed on "two pairs"
   1,1,2,3,3 scores 8 (1+1+3+3)
   1,1,2,3,4 scores 0
   1,1,2,2,2 scores 0

Three of a kind:
  If there are three dice with the same number, the player
  scores the sum of these dice.
    For example, when placed on "three of a kind"
    3,3,3,4,5 scores 9 (3+3+3)
    3,3,4,5,6 scores 0
    3,3,3,3,1 scores 0

Four of a kind:
  If there are four dice with the same number, the player
  scores the sum of these dice.
    For example, when placed on "four of a kind"
    2,2,2,2,5 scores 8 (2+2+2+2)
    2,2,2,5,5 scores 0
    2,2,2,2,2 scores 0

Small straight:
  When placed on "small straight", if the dice read
    1,2,3,4,5, the player scores 15 (the sum of all the dice.

Large straight:
  When placed on "large straight", if the dice read
    2,3,4,5,6, the player scores 20 (the sum of all the dice).

Full house:
  If the dice are two of a kind and three of a kind, the
  player scores the sum of all the dice.
    For example, when placed on "full house"
    1,1,2,2,2 scores 8 (1+1+2+2+2)
        2,2,3,3,4 scores 0
    4,4,4,4,4 scores 0
