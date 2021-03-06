require './tile.rb'
require './board.rb'
require 'byebug'
require 'yaml'

class MineSweeper

  def initialize(board_size=9, number_of_mines=12)
    @board = Board.new(board_size, number_of_mines)
    @board.set_mines
    @board.set_numbers
  end

  def play
    puts "Would you like to load a game? (y/n)"
    load_option = gets.chomp.downcase
    until load_option == "y" || load_option == "n"
      puts "Invalid option, would you like to load a game? (y/n)"
      load_option = gets.chomp.downcase
    end

    load_file if load_option == "y"

    loop do
      @board.draw_board
      move = get_move
      if move == "s"
        save_file
        puts "File Saved! (I think)"
        break
      end
      coord = get_coordinate(move)
      @board.update(move, coord)
      break if @board.lost? || @board.won?

    end
    @board.draw_board
    puts "You lost!" if @board.lost?
    puts "You win!" if @board.won?

  end

  def load_file
    puts "What's the name of the save file?"

    file_name = gets.chomp.downcase
    until File.exist?(file_name)
      puts "Invalid filename, try again or type 'c' to cancel load"
      file_name = gets.chomp.downcase
      return nil if file_name == "c"
    end

    input = YAML::load(File.read(file_name))
    @board = input if input.is_a?(Board)
    nil
  end

  def save_file
    File.open("minesweeper_save.txt", 'w') do |f|
      f.puts @board.to_yaml
    end
  end

  def get_move
    puts "Would you like to reveal or flag? (r/f)"
    puts "You can also save the game with 's'."
    selection = gets.chomp.downcase
    while selection != "r" && selection != "f" && selection != "s"
      puts "Invalid input, would you like to reveal, flag or safe? (r/f/s)"
      selection = gets.chomp.downcase
    end

    selection
  end

  def get_coordinate(move_type)
      valid_move = false
      until valid_move
        valid_move = true
        puts "Please choose a coordinate"
        coordinate = gets.chomp.split(",").map(&:to_i)
        #debugger
        if move_type == "r"
          valid_move = !@board.revealed_coords.include?(coordinate) &&
            @board.in_bounds?(coordinate) &&
            !@board.flagged_coords.include?(coordinate)
        else
          valid_move = !@board.revealed_coords.include?(coordinate) &&
            @board.in_bounds?(coordinate)
        end
        puts "Not a valid coordinate, try again." unless valid_move
      end

    coordinate
  end

end
