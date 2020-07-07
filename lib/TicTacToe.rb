class Board
	def initialize
		@position = [1, 2, 3, 4, 5, 6, 7, 8, 9]
	end
	attr_accessor :position

	def display
		puts "     #     #     "
		puts "  #{@position[0]}  #  #{@position[1]}  #  #{@position[2]}  "
		puts "     #     #     "
		puts "#################"
		puts "     #     #     "
		puts "  #{@position[3]}  #  #{@position[4]}  #  #{@position[5]}  "
		puts "     #     #     "
		puts "#################"
		puts "     #     #     "
		puts "  #{@position[6]}  #  #{@position[7]}  #  #{@position[8]}  "
		puts "     #     #     "
	end

	def fill(slot, player)
		slot_to_array_index = slot.to_i - 1
		#might be able to change this by having the comandline input be read as an integer
		if slot_to_array_index >= 0 and slot_to_array_index <= 9 and position[slot_to_array_index].class == Integer

			position[slot_to_array_index] = player[:player_char]
		#else
			#puts to console that the input was invalid
			return true
		end
		return false
	end
end

class Controller
	# dependency injection pattern with default self is used here for testability
	def initialize(data_collector = self)

		player_data = data_collector.get_player_data
		@player1 = player_data[0]
		@player2 = player_data[1]
		@game_board = Board.new
	end

	attr_reader :player1
	attr_reader :player2
	attr_reader :game_board

	def get_player_data
		puts "Player 1 please enter your name"
		p1_name = gets.chomp
		p2_name = ""
		p2_character = ""
		p1_character = ""

		3.times do
			puts p1_name + ", select X or O"
			p1_character = gets.chomp.upcase
			if p1_character == "X"
				p2_character = "O"
				break
			elsif p1_character == "O"
				p2_character = "X"
				break
			else
				next
			end
		end

		if p1_character != "X" and p1_character != "O"
			puts "goodbye"
			return
		end


		puts "player 2, you are #{p2_character}, please enter your name"
		4.times do
			p2_name = gets.chomp
			if p2_name != p1_name
				break
			else
				puts "player 2, please enter a different name"
			end
		end

		if p2_name == p1_name
			p2_name = "player 2"
		end

		return [{name: p1_name, player_char: p1_character}, {name: p2_name, player_char: p2_character}]
	end
end

class Game
	def initialize
		@controller = Game.get_controller
		@active_player = @controller.player1
		start
	end

	attr_reader :controller
	attr_reader :active_player

	def self.get_controller
		Controller.new
	end

	#TODO FIX
	def switch_active_player
		if @active_player.equal?(@controller.player1)
			@active_player = @controller.player2
		else
			@active_player = @controller.player1
		end
	end

	def end_condition
		grid = @controller.game_board.position

		if (grid[0] == grid[1] and grid[0] == grid[2]) or
			(grid[3] == grid[4] and grid[3] == grid[5]) or
			(grid[6] == grid[7] and grid[6] == grid[8]) or
			(grid[0] == grid[3] and grid[0] == grid[6]) or
			(grid[1] == grid[4] and grid[1] == grid[7]) or
			(grid[2] == grid[5] and grid[2] == grid[8]) or
			(grid[0] == grid[4] and grid[0] == grid[8]) or
			(grid[2] == grid[4] and grid[2] == grid[6])

			return @active_player
		else
			if grid.any? {|x| x.is_a? Integer}
				return false
			else
				return true
			end
		end
	end

	def start
		winner = nil
		loop do
		@controller.game_board.display
		puts "#{@active_player[:name]} select a board position"

			unless @controller.game_board.fill(gets.chomp, @active_player)
				puts "INVALID BOARD POSITION"
				next
			end

			winner = end_condition
			break if winner

			switch_active_player
		end

		@controller.game_board.display
		if winner.equal?(@active_player)
			puts "Congratulations #{@active_player[:name]}! \"#{@active_player[:player_char]}\" Wins!"
		else
			puts "DRAW"
		end
	end
end

Game.new