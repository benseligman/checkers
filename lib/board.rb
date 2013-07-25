require_relative "piece"

class InvalidMoveError < StandardError; end

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
      position, color, king = piece.position, piece.color, piece.king?
      dup.place_piece(position, color, king)
    end

    dup
  end

  def perform_jump(origin, destination)
    perform_move("jump", origin, destination)
    jumped = Board.in_between(origin, destination)
    self[jumped] = nil
  end

  def perform_slide(origin, destination)
    perform_move("slide", origin, destination)
  end

  def place_piece(color, position, king = false)
    self[position] = Piece.new(color, position, self)
  end

  def self.in_between(origin, destination)
    Board.sum_vectors(origin, destination).map { |coord| coord / 2 }
  end

  def self.sum_vectors(vector1, vector2)
    vector1.each_index.map { |i| vector1[i] + vector2[i] }
  end

  def set_pieces
    set_team_pieces([0, 1, 2], :black)
    set_team_pieces([5, 6, 7], :red)
    self
  end

  def to_s
    @rows.map do |row|
      row.map do |square|
        square.nil? ? "   " : " #{square} "
      end.join("|")
    end.join("\n--------------------------------\n")
  end

  protected

  def []=(position, piece)
    i, j = position
    @rows[i][j] = piece
    piece.position = position unless piece.nil?
  end

  private

  def empty?(position)
    raise IndexError unless on_board?(position)
    self[position].nil?
  end

  def on_board?(position)
    position.all? { |coord| coord.between?(0, 7) }
  end

  def perform_move(type, origin, destination)
    piece = self[origin]
    move_type_method = (type + "_moves").to_sym

    unless piece.send(move_type_method).include?(destination)
      raise InvalidMoveError.new("The piece at #{origin} can't move to #{destination}!")
    end

    self[destination] = piece
    self[origin] = nil
  end

  def pieces
    @rows.flatten.compact
  end

  def set_team_pieces(rows, color)
    rows.each do |row|
      8.times do |col|
        place_piece(color, [row, col]) if (row + col).odd?
      end
    end
  end
end