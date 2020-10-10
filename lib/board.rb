require_relative 'ship'
require 'terminal-table/import'

class Board
  attr_reader :board, :ships, :player_name

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
    (1..7).each_with_object(new_board) do |row_number, new_board|
      new_board << row_with_number(row_number)
    end
  end

  def new_board
    [header]
  end

  def header
    [" ","A", "B", "C", "D", "E", "F", "G"]
  end

  def row_with_number(int)
    [int.to_s, WATER, WATER, WATER, WATER, WATER, WATER, WATER]
  end

  def print_board
    puts Terminal::Table.new :title => "#{@player_name} Board:", :rows => @board
  end

  def place_ships
    @ships << Ship.new(4)
    @ships << Ship.new(3)
    @ships << Ship.new(2)
    @ships << Ship.new(2)
    
    @ships.each do |ship|
      place_ship(ship)
    end
  end

  def ai_place_ships
    @ships << Ship.new(4)
    @ships << Ship.new(3)
    @ships << Ship.new(2)
    @ships << Ship.new(2)
    @ships.each do |ship|
      place_ai_ship(ship)
    end
  end

  def place_ship(ship)
    system "clear"
    while true do
      puts "Please place your ship of size: #{ship.size}"
      print_board
      location = get_location
      direction = get_direction
      unless validate_fits_on_board(location, direction, ship)
        next
      end
      ship_coordinates = populate_ship_coordinates(location, direction, ship)
      unless validate_not_clashing(ship_coordinates)
        puts "There is already a ship there. Don't crash your ships into each other, let the enemy sink them."
        next
      end
      add_ship_to_board(ship_coordinates, ship)
      break
    end
  end

  def place_ai_ship(ship)
    while true do
      location = get_ai_location
      direction = get_ai_direction
      unless validate_fits_on_board(location, direction, ship)
        next
      end
      ship_coordinates = populate_ship_coordinates(location, direction, ship)
      unless validate_not_clashing(ship_coordinates)
        next
      end
      add_ship_to_board(ship_coordinates, ship)
      break
    end
  end

  def get_location
    valid = false
    user_input = ""
    until valid do
      puts "Enter a set of coordinates with letter first, no spaces (eg. A1)"
      user_input = gets.chomp
      valid = validate_input(user_input)
    end
    row = user_input[1].to_i
    column = COLUMN_CONVERTER[user_input[0].upcase]
    coordinates = [row, column]
    coordinates
  end

  def get_ai_location
    row = rand(1..7)
    column = rand(1..7)
    coordinates = [row, column]
    coordinates
  end
  
  def get_direction
    while true do
      puts "Enter direction for your ship to face (up, down, left, right)"
      direction = gets.chomp.downcase
      if ["up", "down", "left", "right"].include?(direction)
        return direction
      else
        puts "Invalid direction, please try again."
      end
    end
  end

  def get_ai_direction
    directions = ["up", "down", "left", "right"]
    direction = directions[rand(0..4)]
    direction
  end

  def validate_input(coordinates)
    valid = true
    valid = false unless coordinates.length == 2
    valid = false unless coordinates[0] =~ /[A-Ga-g]/
    valid = false unless coordinates[1] =~ /[1-7]/
    unless valid
      puts "Invalid input, please try again"
    end
    return valid
  end

  def validate_fits_on_board(coordinates, direction, ship)
    row = coordinates[0]
    column = coordinates[1]
    direction_valid = false
    #check if ship fits on board
    if direction == "up" && (row - ship.size < 0)
      puts "Ship does not fit."
    elsif direction == "down" && (row + ship.size > 7)
      puts "Ship does not fit."
    elsif direction == "left" && (column - ship.size < 0)
      puts "Ship does not fit."
    elsif direction == "right" && (column + ship.size > 7)
      puts "Ship does not fit."
    else
      direction_valid = true
    end
    direction_valid
  end

  def validate_not_clashing(ship_coordinates)
    @ships.each do |ship|
      ship.coords.each do |coord|
        if ship_coordinates.include?(coord)
          return false
        end
      end
    end
    true
  end

  def populate_ship_coordinates(coordinates, direction, ship)
    ship_coordinates = []
    row = coordinates[0]
    column = coordinates[1]
    ship_coordinates << coordinates
    case direction
    when "up"
      for i in 1..(ship.size - 1) do
        ship_coordinates << [row - i, column]
      end
    when "down"
      for i in 1..(ship.size - 1) do
        ship_coordinates << [row + i, column]
      end
    when "left"
      for i in 1..(ship.size - 1) do
        ship_coordinates << [row, column - i]
      end
    when "right"
      for i in 1..(ship.size - 1) do
        ship_coordinates << [row, column + i]
      end
    end
    ship_coordinates
  end

  def add_ship_to_board(coordinates, ship)
    coordinates.each do |coord|
      ship.coords << [coord[0],coord[1]]
      unless @player_name == "AI"
        @board[coord[0]][coord[1]] = BOAT
      end
    end
  end

  def check_valid_strike(strike)
    return @board[strike[0]][strike[1]] == WATER
  end

  def check_hit(strike, player_name)
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
    end
    print_results(strike, hit, destroyed, player_name)
  end

  def print_results(strike, hit, destroyed, player_name)
    system "clear"
    if destroyed
      puts "#{player_name} destroyed a ship!"
      @board[strike[0]][strike[1]] = EXPLOSION
    elsif hit
      puts "#{player_name} hit!"
      @board[strike[0]][strike[1]] = EXPLOSION
    else
      puts "#{player_name} missed!"
      @board[strike[0]][strike[1]] = MISS
    end
  end
end