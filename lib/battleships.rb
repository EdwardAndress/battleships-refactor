require 'terminal-table/import'
require 'colorize'
require_relative 'ship'
require_relative 'board'

# table = Terminal::Table.new :rows => rows

class Game

  COLUMN_CONVERTER = {"A" => 1, "B" => 2, "C" => 3, "D" => 4, "E" => 5, "F" => 6, "G" => 7}
  MISS = "\u{274C}"

  def initialize
    @playerBoard = Board.new("player")
    @aiBoard = Board.new("ai")
  end

  def playerMove
    puts "Enter row to strike:"
    row = gets.chomp.to_i
    puts "Enter column to strike:"
    column = COLUMN_CONVERTER[gets.chomp.upcase]
    strike = [row, column]
    @aiBoard.check_hit(strike)
  end

  def aiMove
    while true
      row = rand(1..7)
      column = rand(1..7)
      strike = [row, column]
      if @playerBoard.board[strike[0]][strike[1]] != MISS
        break
      end
    end
    @playerBoard.check_hit(strike)
  end

  #Unfinished
  def runGame
    gameRunning = true
    @aiBoard.aiPlaceShips
    @playerBoard.placeShips
    system "clear"
    @playerBoard.print_board
    @aiBoard.print_board
    while gameRunning == true
      playerMove
      aiMove
      @playerBoard.print_board
      @aiBoard.print_board
      if @playerBoard.ships.length == 0
        puts "You lose!"
        break
      elsif @aiBoard.ships.length == 0
        puts "You win!"
        break
      end
    end
  end

end

game = Game.new
game.runGame
