require_relative 'ship'
require 'terminal-table/import'

class Board
  attr_reader :board, :ships

  
  WATER = "\u{1F30A}"
  BOAT = "\u{1F6A2}"
  EXPLOSION = "\u{1F4A5}"
  MISS = "\u{274C}"
  COLUMN_CONVERTER = {"A" => 1, "B" => 2, "C" => 3, "D" => 4, "E" => 5, "F" => 6, "G" => 7}

  def initialize(player_name)
    @player_name = player_name
    @board = create_board
    @ships = []
  end

  def create_board
    rows = []
    rows << [" ","A", "B", "C", "D", "E", "F", "G"]
    rows << ["1", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
    rows << ["2", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
    rows << ["3", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
    rows << ["4", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
    rows << ["5", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
    rows << ["6", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
    rows << ["7", WATER, WATER, WATER, WATER, WATER, WATER, WATER]
    
    rows
  end

  def print_board
    puts Terminal::Table.new :title => "#{@player_name} Board:", :rows => @board
  end

  def placeShips
    @ships << Ship.new(4)
    @ships << Ship.new(3)
    @ships << Ship.new(2)
    @ships << Ship.new(2)
    row = 0
    column = ""
    direction = ""
    @ships.each do |ship|
      system "clear"
      puts Terminal::Table.new :title => "Your Board:", :rows => @board
      puts "Please place your ship of size: #{ship.size}"
      puts "Enter a row to start your ship on (1-7)."
      row = gets.chomp.to_i
      puts "Enter a column to start your ship on (A-G)"
      column = gets.chomp

      #Loop to get direction until valid
      while true
        # Input validation
        while true
          puts "Enter direction for your ship to face (up, down, left, right)"
          direction = gets.chomp
          if direction != "up" && direction != "down" && direction != "left" && direction != "right"
            puts "Invalid direction."
          else
            break
          end
        end
        if direction == "up" && (row - (ship.size - 1) < 0)
          puts "Ship does not fit."
        elsif direction == "down" && (row + (ship.size - 1) > 7)
          puts "Ship does not fit."
        elsif direction == "left" && (COLUMN_CONVERTER[column.upcase] - (ship.size - 1) < 0)
          puts "Ship does not fit."
        elsif direction == "right" && (COLUMN_CONVERTER[column.upcase] + (ship.size - 1) > 7)
          puts "Ship does not fit."
        else
          break
        end
      end

      #Set ship coords
      shipCoords = []
      shipCoords << [row, COLUMN_CONVERTER[column.upcase]]
      case direction
      when "up"
        for i in 1..(ship.size - 1) do
          shipCoords << [row - i, COLUMN_CONVERTER[column.upcase]]
        end
      when "down"
        for i in 1..(ship.size - 1) do
          shipCoords << [row + i, COLUMN_CONVERTER[column.upcase]]
        end
      when "left"
        for i in 1..(ship.size - 1) do
          shipCoords << [row, COLUMN_CONVERTER[column.upcase] - i]
        end
      when "right"
        for i in 1..(ship.size - 1) do
          shipCoords << [row, COLUMN_CONVERTER[column.upcase] + i]
        end
      end

      # Place ships on board
      shipCoords.each do |coord|
        @board[coord[0]][coord[1]] = BOAT
        ship.coords << [coord[0],coord[1]]
      end
    end
  end

  def aiPlaceShips
    directions = ["right", "left", "up", "down"]
    @ships << Ship.new(4)
    @ships << Ship.new(3)
    @ships << Ship.new(2)
    @ships << Ship.new(2)
    @ships.each do |ship|
      # while true to re-place if ship clashes
      shipPlaced = false
      while shipPlaced == false
        row = rand(1..7)
        column = rand(1..7)
        direction = ""
        # Sets random direction until valid
        while true
          direction = directions[rand(0..4)]
          if direction == "up" && (row - ship.size >= 0)
            break
          elsif direction == "down" && (row + ship.size <= 7)
            break
          elsif direction == "left" && (column - ship.size >= 0)
            break
          elsif direction == "right" && (column + ship.size <= 7)
            break
          end
        end

        # Pushes ship coordinates
        shipCoords = []
        shipCoords << [row, column]
        case direction
        when "up"
          for i in 1..(ship.size - 1) do
            shipCoords << [row - i, column]
          end
        when "down"
          for i in 1..(ship.size - 1) do
            shipCoords << [row + i, column]
          end
        when "left"
          for i in 1..(ship.size - 1) do
            shipCoords << [row, column - i]
          end
        when "right"
          for i in 1..(ship.size - 1) do
            shipCoords << [row, column + i]
          end
        end

        # Checks if ship clashes with previously placed ships
        clashing = false
        shipCoords.each do |coord|
          @ships.each do |aiShip|
            aiShip.coords.each do |coord2|
              if coord == coord2
                clashing = true
              end
            end
          end
        end

        # Places ship if not clashing
        if !clashing
          shipCoords.each do |coord|
            # For testing AI placement: @opBoard[coord[0]][coord[1]] = boat
            ship.coords << [coord[0],coord[1]]
          end
          shipPlaced = true
        end
      end
    end
  end

  def check_hit(strike)
    hit = false
    destroyed = false

    # Checks if strike is true
    @ships.each do |ship|
      ship.coords.each do |coord|
        if strike == coord
          hit = true
          ship.damage
          if ship.isDead
            destroyed = true
            @ships.delete(ship)
          end
          break
        end
      end
      if hit
        break
      end
    end
    system "clear"
    if destroyed
      puts "You destroyed a ship!"
      @board[strike[0]][strike[1]] = EXPLOSION
    elsif hit
      puts "You hit!"
      @board[strike[0]][strike[1]] = EXPLOSION
    else
      puts "You missed!"
      @board[strike[0]][strike[1]] = MISS
    end
  end

end