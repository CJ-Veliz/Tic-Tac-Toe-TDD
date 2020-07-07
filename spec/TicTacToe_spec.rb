require './lib/TicTacToe'

describe Board do
	before do
		@game_board = Board.new
	end

	it "allow read access to its board possitions" do
		expect(@game_board).to respond_to(:position)
	end

	describe '#display' do
		empty_board_regex =
		/\s+#\s+#\s+\d\s+#\s+\d\s+#\s+\d\s+#\s+#\s+#+\s+#\s+#\s+\d\s+#\s+\d\s+#\s+\d\s+#\s+#\s+#+\s+#\s+#\s+\d\s+#\s+\d\s+#\s+\d\s+#\s+#\s+/

		it "should print an empty board out to the interface from a new board" do
			expect do
				@game_board.display
			end.to output(empty_board_regex).to_stdout
		end

		it "should not print out an empty board when a slot has been filled" do
			expect do
				@game_board.position[0] = "X"
				@game_board.display
			end.to_not output(empty_board_regex).to_stdout
		end
	end


	describe '#fill' do
		test_player = {name: "test_player", player_char: "T"}

		it 'should return True with valid arguements(1 <= arg <= 9)' do
			expect(@game_board.fill("7", test_player)).to be(true)
		end

		it 'should return False with invalid arguements(arg.to_i < 1 or arg.to_i > 9)' do
			expect(@game_board.fill("invalid data", test_player)).to be(false)
		end

		it "should modify the positions array if the slot passed in as an arguement has not yet been filled" do
			test_positions = @game_board.position.clone

			@game_board.fill("5", test_player)
			expect(@game_board.position).not_to eq(test_positions)
		end

		it "should insert the correct player character data into the boards posstions array with arguement slots using one-based indexing)" do
			slot_to_fill = "5"
			slot_array_index = slot_to_fill.to_i - 1

			@game_board.fill(slot_to_fill, test_player)
			expect(@game_board.position[slot_array_index]).to eq(test_player[:player_char])
		end

		it "should not modify the positions array if the slot passed in as an arguement has already been filled" do
			test_player_one = {name: "test_player", player_char: "T"}
			test_player_two = {name: "test_player_two", player_char: "U"}

			@game_board.fill("5", test_player_one)
			test_positions = @game_board.position.clone
			@game_board.fill("5", test_player_two)

			expect(@game_board.position).to eq(test_positions)
		end
	end
end


describe Controller do
	describe "#initialize" do

		it "calls the data collector role to acquire player data" do
			collector = spy('data collector injection')
			controller = Controller.new(collector)
			expect(collector).to have_received(:get_player_data)
		end

		it "stores player input" do
			collector = double("provides player data")
			allow(collector).to receive(:get_player_data).and_return([{name: "Carlos", player_char: "X"}, {name: "Jonathan", player_char: "O"}])
			controller = Controller.new(collector)

			expect(controller.player1).to eq({name: "Carlos", player_char: "X"})
			expect(controller.player2).to eq({name: "Jonathan", player_char: "O"})
		end

		it "instantiates its own new game board and keeps a reference" do 
			expect(Board).to receive(:new).and_call_original

			collector = double
			allow(collector).to receive(:get_player_data).and_return([{name: "Carlos", player_char: "X"}, {name: "Jonathan", player_char: "O"}])
			controller = Controller.new(collector)

			expect(controller.game_board).to be_an_instance_of(Board)
		end
	end


	describe "#get_player_data" do
		before do
			collector = double("provides player data")
			expect(collector).to receive(:get_player_data).and_return([{name: "Carlos", player_char: "X"}, {name: "Jonathan", player_char: "O"}])
			@controller = Controller.new(collector)

			# this stub is placed here to get rid of console outpute during tests
			allow($stdout).to receive(:puts)
		end

		it "queries the user for input and returns the information" do

			expect(@controller).to receive(:gets).and_return("Carlos", "X", "Jonathan")
			expect(@controller.get_player_data).to eq([{name: "Carlos", player_char: "X"}, {name: "Jonathan", player_char: "O"}])
		end

		# TODO Fix outcome
		it "attempts to assign game character X or O to player1 3 times" do

			expect(@controller).to receive(:gets).and_return("firstname", "Z", "Z", "Z")
			expect{@controller.get_player_data}.to output(/goodbye/).to_stdout
		end

		# TODO fix regex for end of line matching only
		it "asks player2 to enter a different name is they input the same name as player1" do

			expect(@controller).to receive(:gets).and_return("Mark", "X", "Mark", "aaa")
			expect{@controller.get_player_data}.to output(/player 2, please enter a different name/).to_stdout
		end

		it "allows player2 to retry entering their name multiple times" do

			expect(@controller).to receive(:gets).and_return("player1_name", "O", "player1_name", "player1_name", "different_name")
			expect(@controller.get_player_data).to eq([{name: "player1_name", player_char: "O"}, {name: "different_name", player_char: "X"}])
		end

		it "attempts to assign a name to player2 at most four times. Uses default 'player2' upon failure" do

			expect(@controller).to receive(:gets).and_return("player1_name", "O", "player1_name", "player1_name", "player1_name", "player1_name")
			expect(@controller.get_player_data).to eq([{name: "player1_name", player_char: "O"}, {name: "player 2", player_char: "X"}])
		end
	end
end

describe Game do
	before do
		@game_controller = double("controller substitute")
		allow(Controller).to receive(:new).and_return(@game_controller)
		allow(@game_controller).to receive(:player1).and_return({name: "Player_1_name", player_char: "O"})
		allow(@game_controller).to receive(:player2).and_return({name: "Player_2_name", player_char: "X"})
		allow_any_instance_of(Game).to receive(:start)
		@game = Game.new
	end

	describe "#initialize" do

		it "call method to create controller and store reference" do
			test_controller = double
			expect(Game).to receive(:get_controller).and_return(test_controller)

			allow(test_controller).to receive(:player1)
			game = Game.new
			expect(game.controller).to be(test_controller)
		end

		it "initially sets the active player to player 1" do

			allow(Controller).to receive(:new).and_return(@game_controller)
			allow(@game_controller).to receive(:player1).and_return({name: "Carlos", player_char: "X"})
			game = Game.new
			expect(game.active_player). to be(@game_controller.player1)
		end
	end

	describe "#get_controller" do
		it "returns a new controller object" do
			collector = double("player data collector")
			allow(collector).to receive(:get_player_data).and_return([{name: "Carlos", player_char: "X"}, {name: "Jonathan", player_char: "O"}])

			# since :unstub is deprecated, use :and_call_original for same function, then override
			allow(Controller).to receive(:new).and_call_original
			expect(Controller).to receive(:new).and_return(Controller.new(collector))
			expect(Game.get_controller).to be_an_instance_of(Controller)
		end
	end

	describe "#switch_active_player" do

		it "changes the active player to player 2 when player 1 was active" do
			previous_player = @game.active_player

			@game.switch_active_player
			expect(@game.active_player).to_not be(previous_player)
			expect(@game.active_player).to be(@game.controller.player2)
		end

		it "changes the active player to player 1 when player 2 was active" do
			@game.instance_variable_set(:@active_player, @game.controller.player2)
			previous_player = @game.active_player

			@game.switch_active_player
			expect(@game.active_player).to_not be(previous_player)
			expect(@game.active_player).to be(@game.controller.player1)
		end
	end

	describe '#start' do
		before do
			# game_controller = double("controller substitute")
			# expect(Controller).to receive(:new).and_return(game_controller)
			# allow(game_controller).to receive(:player1).and_return({name: "One", player_char: "O"})
			# allow(game_controller).to receive(:player2).and_return({name: "Two", player_char: "X"})
			# @game = Game.new

			@valid = "acceptable_input"
			@not_valid = "invalid_input"
			game_board_double = double("TicTacToe Board")
			allow(game_board_double).to receive(:fill).with(@not_valid, anything).and_return(false)
			allow(game_board_double).to receive(:fill).with(@valid, anything).and_return(true)

			allow(@game.controller).to receive(:game_board).and_return(game_board_double)
			allow(@game).to receive(:end_condition).and_return(true)
			allow($stdout).to receive(:write)

			expect(@game).to receive(:start).and_call_original
		end

		it 'should display the game board on every iteration of the main game loop' do
			allow(@game).to receive(:gets).and_return(@valid)
			expect(@game.controller.game_board).to receive(:display).at_least(:twice)
			@game.start
		end

		it 'directs the player whose turn it is to play, to select a position on the board to fill' do
			allow(@game).to receive(:gets).and_return(@valid)
			expect{@game.start}.to output(/#{@game.active_player[:name]} select a board position/).to_stdout
		end

		it 'calls the fill method of its model, provided with acceptable input' do
			allow(@game).to receive(:gets).and_return(@valid)

			expect(@game.controller.game_board).to receive(:fill).with(@valid, @game.active_player).and_return(true)
			@game.start
		end

		it 'provided with invalid input, delegate validation to Board#fill' do
			allow(@game).to receive(:gets).and_return(@not_valid)

			expect(@game.controller.game_board).to receive(:fill).with(@not_valid, @game.active_player).and_return(true)
			@game.start
		end

		it 'informs the player of their invalid input' do
			allow(@game).to receive(:gets).and_return(@not_valid, @valid)
			expect{@game.start}.to output(/INVALID BOARD POSITION/).to_stdout
		end

		it "does not switch the active player when they select an invalid action" do
			allow(@game).to receive(:gets).and_return(@not_valid, @not_valid, @valid)

			expect(@game).to receive(:switch_active_player).at_most(:once)
			@game.start
		end

		it "switches the active player after valid input" do
			allow(@game).to receive(:gets).and_return(@valid)
			allow(@game).to receive(:end_condition).and_return(false, true)
			expect(@game).to receive(:switch_active_player)
			@game.start
		end

		it "prints 'draw' out to the console if the game is a tie" do
			allow(@game).to receive(:gets).and_return(@valid)
			expect{@game.start}.to output(/DRAW/).to_stdout
		end

		it "names the winner if there is one" do
			allow(@game).to receive(:gets).and_return(@valid)
			allow(@game).to receive(:end_condition).and_return(@game.controller.player1)
			expect{@game.start}.to output(/Congratulations #{@game.controller.player1[:name]}!/).to_stdout
		end
	end

	describe "#end_condition" do
		before do
			allow(@game.controller).to receive(:game_board).and_return(Board.new)
		end

		it "determines the game should end when all slots have been filled, returns true for a draw" do
			@game.controller.game_board.instance_variable_set(:@position, ["X", "O", "X", "X", "O", "X", "O", "X", "O"])
			expect(@game.end_condition).to be(true)
		end

		it "does not return true, when all slots have been filled but there is a winning player" do
			@game.controller.game_board.instance_variable_set(:@position, ["X", "O", "X", "O", "O", "X", "O", "X", "X"])

			winner = @game.end_condition
			expect(winner).to_not be(true)
			expect(winner).to be(@game.active_player)
		end

		it "returns false when not all board slots have been filled and there is yet no winning player" do
			@game.controller.game_board.instance_variable_set(:@position, [1, "O", "X", "X", "O", "X", "O", "X", "O"])
			expect(@game.end_condition).to be(false)
		end

		it "determines three in a row wins (column left) the game and returns winning player" do
			@game.controller.game_board.position[0] = "X"
			@game.controller.game_board.position[3] = "X"
			@game.controller.game_board.position[6] = "X"
			expect(@game.end_condition).to be(@game.active_player)
		end

		it "determines three in a row wins (column middle) the game and returns winning player" do
			@game.controller.game_board.position[1] = "O"
			@game.controller.game_board.position[4] = "O"
			@game.controller.game_board.position[7] = "O"
			expect(@game.end_condition).to be(@game.active_player)
		end

		it "determines three in a row wins (column right) the game and returns winning player" do
			@game.controller.game_board.position[2] = "O"
			@game.controller.game_board.position[5] = "O"
			@game.controller.game_board.position[8] = "O"
			expect(@game.end_condition).to be(@game.active_player)
		end

		it "determines three in a row wins (row top) the game and returns winning player" do
			@game.controller.game_board.position[0] = "X"
			@game.controller.game_board.position[1] = "X"
			@game.controller.game_board.position[2] = "X"
			expect(@game.end_condition).to be(@game.active_player)
		end

		it "determines three in a row wins (row middle) the game and returns winning player" do
			@game.controller.game_board.position[3] = "X"
			@game.controller.game_board.position[4] = "X"
			@game.controller.game_board.position[5] = "X"
			expect(@game.end_condition).to be(@game.active_player)
		end

		it "determines three in a row wins (row bottom) the game and returns winning player" do
			@game.controller.game_board.position[6] = "O"
			@game.controller.game_board.position[7] = "O"
			@game.controller.game_board.position[8] = "O"
			expect(@game.end_condition).to be(@game.active_player)
		end

		it "determines three in a row wins (diagonal '/') the game and returns winning player" do
			@game.controller.game_board.position[6] = "O"
			@game.controller.game_board.position[4] = "O"
			@game.controller.game_board.position[2] = "O"
			expect(@game.end_condition).to be(@game.active_player)
		end

		it "determines three in a row wins (diagonal '\\') the game and returns winning player" do
			@game.controller.game_board.position[0] = "X"
			@game.controller.game_board.position[4] = "X"
			@game.controller.game_board.position[8] = "X"
			expect(@game.end_condition).to be(@game.active_player)
		end
	end
end