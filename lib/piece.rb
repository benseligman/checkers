require 'debugger'

class Piece
  attr_accessor :position
  attr_reader :king, :color

  def initialize(color, position, board, king = false)
    @color, @position, @board, @king = color, position, board, king
  end

  alias_method :king?, :king

  def orientation
    return [1, -1] if king?
    (@color == :red) ? [-1] : [1]
  end

  def jump_moves
    candidates = candidate_moves(2)

    candidates.reject do |candidate|
      in_between = Board.in_between(@position, candidate)
      @board.available_square?(in_between) || @board[in_between].color == @color
    end
  end

  def slide_moves
    candidate_moves(1)
  end

  def to_s
    @color[0].upcase
  end

  private

  def candidate_moves(distance)
    moves = []
    horizontal_deltas = [-1, 1].map { |delta| delta * distance }
    vertical_deltas = orientation.map { |delta| delta * distance }

    vertical_deltas.each do |v_delta|
      horizontal_deltas.each do |h_delta|
        candidate = Board.sum_vectors(@position, [v_delta, h_delta])
        moves << candidate if @board.available_square?(candidate)
      end
    end

    moves
  end
end