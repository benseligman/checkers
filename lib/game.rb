require_relative "./board"
require_relative "./players/human_player"
class Game
  def initialize(red, black)
    @board = Board.populated_board
    @players = {red: red, black: black}
    @to_play = :red
  end

  def self.new_game(p1, p2)
    self.new(p1, p2).play
  end

  def play
    until @board.lost?(@to_play)
      play_turn
    end

    puts "The #{ @to_play } player loses!"
  end

  private

  def play_turn
    begin
      move = @players[@to_play].move(@board)
      origin = move[0][0]

      unless my_piece?(@board[origin], @to_play)
        raise InvalidMoveError.new("Move your own piece.")
      end

      @board.perform_moves(move)
      toggle_player
    rescue InvalidMoveError => e
      puts "Your move was invalid. #{e.message}."
    end
  end

  def toggle_player
    @to_play = (@to_play == :red) ? :black : :red
  end

  def my_piece?(piece, color)
    !piece.nil? && piece.color == color
  end
end