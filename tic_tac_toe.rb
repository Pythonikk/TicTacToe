# frozen_string_literal: true

# defines a player in the game
class Player
  attr_reader :token, :number
  attr_accessor :name, :goes_first, :last_move, :wins

  def initialize(number, token, coin_side)
    @number = number
    @token = token
    @coin_side = coin_side
    set_name
    @goes_first = false
    @last_move = false
    @wins = 0
  end

  def set_name
    puts "\n\nPlayer #{@number} will play token #{@token} and choose #{@coin_side} on the coin flip. What is your name?"
    @name = gets.chomp
  end
end

# defines who goes first
class Coin
  def initialize; end

  def flip(player1, player2)
    puts "\n\nA coin is flung high into the air... \n\n"
    result = flip_result
    print "It turns round and round eventually landing #{result} side up. "
    if result == 'heads'
      player2.goes_first = true
      player1.goes_first = false
      puts "#{player2.name} goes first.\n\n"
    else
      player1.goes_first = true
      player2.goes_first = false
      puts "#{player1.name} goes first.\n\n"
    end
  end

  private

  def flip_result
    %w[heads tails].sample
  end
end

# definine a new board
class Board
  attr_reader :line_a, :line_b, :line_c
  def initialize
    new_board
    print_board
  end

  def new_board
    @line_a = [' ', ' ', ' ']
    @line_b = [' ', ' ', ' ']
    @line_c = [' ', ' ', ' ']
  end

  def update_board(token, position)
    if position[0] == 'a'
      @line_a[position[1].to_i] = token
    elsif position[0] == 'b'
      @line_b[position[1].to_i] = token
    else
      @line_c[position[1].to_i] = token
    end
  end

  def print_board
    puts "      0     1     2      \n\n"
    puts "a  [  #{@line_a[0]}  |  #{@line_a[1]}  |  #{@line_a[2]}  ]"
    puts '   -------------------'
    puts "b  [  #{@line_b[0]}  |  #{@line_b[1]}  |  #{@line_b[2]}  ]"
    puts '   -------------------'
    puts "c  [  #{@line_c[0]}  |  #{@line_c[1]}  |  #{@line_c[2]}  ] \n\n"
  end
end

# initiates new game
class Game
  @@game_number = 0

  def initialize(player1, player2)
    player1.last_move = false
    player2.last_move = false
    game_stats(player1, player2)
    @coin = Coin.new
    @coin.flip(player1, player2)
    @board = Board.new
    first_move(player1, player2)
    play(player1, player2)
  end

  def game_stats(player1, player2)
    @@game_number += 1
    puts "\n\n----------Game #{@@game_number}----------"
    puts "  #{player1.name} : #{player1.wins}     #{player2.name} : #{player2.wins}"
  end

  def first_move(player1, player2)
    if player1.goes_first
      @turn = Turn.new(player1, @board)
    else
      @turn = Turn.new(player2, @board)
    end
  end

  def play(player1, player2)
    loop do
      if @turn.player.number == '1'
        puts "------#{player2.name}'s turn!------\n\n"
        @turn = Turn.new(player2, @board)
      else
        puts "------#{player1.name}'s turn!------\n\n"
        @turn = Turn.new(player1, @board)
      end
      break if @turn.player.last_move
    end
  end
end

# defines behavior of an individual turn
class Turn
  attr_reader :player, :token, :position
  def initialize(player, board)
    @player = player
    @token = @player.token
    @move = PlaceToken.new(board)
    @position = @move.position
    board.update_board(@token, @position)
    board.print_board
    @outcome = Outcome.new(board, @token, @player)
  end
end

# defines the position to be played.
class PlaceToken
  attr_reader :position
  def initialize(board)
    @board = board
    @position = nil
    set_position
  end

  def set_position
    puts "Enter a position to place a token (i.e b1): \n\n"
    @position = gets.chomp
    until valid?
      puts 'Please enter a valid position:'
      @position = gets.chomp
    end
  end

  def valid?
    ('a'..'c').include?(@position[0]) &&
      (0..2).include?(@position[1].to_i) &&
      # the position is not already occupied by another token.
      (board_line(@position)[@position[1].to_i] == ' ')
  end

  def board_line(position)
    return @board.line_a if position[0] == 'a'
    return @board.line_b if position[0] == 'b'
    return @board.line_c if position[0] == 'c'
  end
end

# defines the games end
class Outcome
  attr_reader :token, :board, :name
  def initialize(board, token, player)
    @board = board
    @token = token
    @player = player
    @name = player.name
    @victory = victory?(token)
    @tie = tie?
    cue_end_game if @victory || @tie
  end

  def cue_end_game
    if @victory
      display_victory
      @player.wins += 1
    else
      display_tie
    end
    @player.last_move = true
  end

  def victory?(token)
    a = @board.line_a
    b = @board.line_b
    c = @board.line_c

    a.all?(token) || b.all?(token) || c.all?(token) \
      || a[0] == token && b[0] == token && c[0] == token \
      || a[1] == token && b[1] == token && c[1] == token \
      || a[2] == token && b[2] == token && c[2] == token \
      || a[0] == token && b[1] == token && c[2] == token \
      || a[2] == token && b[1] == token && c[0] == token
  end

  def display_victory
    puts "VICTORY! Congratulations #{@name}, you win!\n\n"
  end

  def tie?
    (@board.line_a).none?(' ') &&
      (@board.line_b).none?(' ') &&
      (@board.line_c).none?(' ')
  end

  def display_tie
    puts 'TIE! Impressive defense. Yayy, lets consider everyone a winner here!'
    puts "(but not the kind of winner that recieves score validation ;p)\n\n"
  end
end

player1 = Player.new('1', 'X', 'tails')
player2 = Player.new('2', 'O', 'heads')
game = Game.new(player1, player2)
play_again = 'y'
while play_again == 'y'
  puts 'Do you want to play again? y/n'
  play_again = gets.chomp
  game = Game.new(player1, player2) if play_again == 'y'
end
