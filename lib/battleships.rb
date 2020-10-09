require_relative 'board'

class Game
  def initialize
    @player_board = Board.new("Player 1")
    @ai_board = Board.new("AI")
  end

  def playerMove
    while true do
      puts "Choose where to attack."
      strike = @player_board.get_location
      if @ai_board.check_valid_strike(strike)
        @ai_board.check_hit(strike, @player_board.player_name)
        break
      else
        puts "You've already attacked there! This isn't an RTS. Choose another location."
        next
      end
    end
  end

  def aiMove
    while true do
      strike = @ai_board.get_ai_location
      if @player_board.check_valid_strike(strike)
        @player_board.check_hit(strike, @ai_board.player_name)
        break
      end
    end
  end

  #Unfinished
  def runGame
    gameRunning = true
    @ai_board.ai_place_ships
    @player_board.place_ships
    system "clear"
    @player_board.print_board
    @ai_board.print_board
    while gameRunning == true
      playerMove
      aiMove
      @player_board.print_board
      @ai_board.print_board
      if @player_board.ships.length == 0
        puts "You lose!"
        break
      elsif @ai_board.ships.length == 0
        puts "You win!"
        break
      end
    end
  end

end

game = Game.new
game.runGame
