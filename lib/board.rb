require_relative "./piece"
require_relative "./exceptions"
require "debugger"

class Board
  def initialize
    @rows = Array.new(8) { Array.new(8) { nil } }
  end

  def self.populated_board
    Board.new.set_pieces
  end

  def [](position)
    i, j = position
    @rows[i][j]
  end

  def available_square?(position)
    on_board?(position) && empty?(position)
  end

  def dup
    dup = Board.new

    pieces.each do |piece|
      position, color, king = piece.color, piece.position, piece.king?
      dup.place_piece(position, color, king)
    end

    dup
  end

  def perform_moves(moves)
    unless valid_move_seq?(moves)
      raise InvalidMoveError.new("Enter a valid move.")
    end

    perform_moves!(moves)
    piece = self[moves.last.last]
    piece.coronate
    nil
  end

  def self.in_between(origin, destination)
    Board.sum_vectors(origin, destination).map { |coord| coord / 2 }
  end

  def self.sum_vectors(vector1, vector2)
    vector1.each_index.map { |i| vector1[i] + vector2[i] }
  end

  def set_pieces
    [0, 1, 2].each { |row| set_row(row, :black) }
    [5, 6, 7].each { |row| set_row(row, :red) }
    self
  end

  def to_s
    @rows.map do |row|
      row.map do |square|
        square.nil? ? "   " : " #{square} "
      end.join("|")
    end.join("\n--------------------------------\n")
  end

  def lost?(color)
    team = pieces.select { |piece| piece.color == color }
    team_moves = team.map { |piece| piece.all_moves }.flatten(1)
    team_moves.empty?
  end

  protected

  def []=(position, piece)
    i, j = position
    @rows[i][j] = piece
    piece.position = position unless piece.nil?
  end

  def place_piece(color, position, king = false)
    self[position] = Piece.new(color, position, self, king)
  end

  def perform_moves!(moves)
    if moves.all? { |move| jump?(move) }
      moves.each do |origin, destination|
        perform_jump(origin, destination)
      end
    elsif slide?(moves.first) && moves.count == 1
      origin, destination = moves.first
      perform_slide(origin, destination)
    else
      raise InvalidMoveError.new("Enter either one slide move or a series of jumps.")
    end
  end

  private

  def empty?(position)
    raise IndexError unless on_board?(position)
    self[position].nil?
  end

  def jump?(move)
    origin, destination = move
    origin.each_with_index.all? { |coord, i| (coord - destination[i]).abs == 2 }
  end

  def on_board?(position)
    position.all? { |coord| coord.between?(0, 7) }
  end

  def perform_move(type, origin, destination)
    debugger
    unless type == :jump_moves || type == :slide_moves
      raise ArgumentError.new("Type must be :jump_moves or :slide_moves.")
    end

    piece = self[origin]

    unless piece.send(type).include?(destination)
      raise InvalidMoveError.new("The piece at #{origin} can't move to #{destination}.")
    end

    self[destination] = piece
    self[origin] = nil

    piece.awaiting_coronation = true if [0, 7].include?(destination[0])
  end

  def perform_jump(origin, destination)
    perform_move(:jump_moves, origin, destination)
    jumped = Board.in_between(origin, destination)
    self[jumped] = nil
  end

  def perform_slide(origin, destination)
    perform_move(:slide_moves, origin, destination)
  end

  def pieces
    @rows.flatten.compact
  end

  def set_row(row, color)
    8.times { |col| place_piece(color, [row, col]) if (row + col).odd? }
  end

  def slide?(move)
    origin, destination = move
    origin.each_with_index.all? { |coord, i| (coord - destination[i]).abs == 1 }
  end

  def valid_move_seq?(moves)
    begin
      dup = self.dup
      dup.perform_moves!(moves)
      true
    rescue StandardError => e
      puts e
      false
    end
  end
end