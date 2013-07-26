class MoveParseError < RuntimeError; end

class HumanPlayer
  def move(board)
    begin
      puts board
      puts "Enter your move as a series of coordinate pairs (y1x1 y2x2 etc.)."
      parse_move(gets)
    rescue MoveParseError => e
      puts e.message
      retry
    end
  end

  private
  def parse_move(move_str)
    move_squares = move_str.split

    unless move_squares.count > 1
      raise MoveParseError.new("You must enter at least two squares.")
    end

    begin
      move_squares.map! do |square|
        square.split("").map{|coord| Integer(coord)}
      end
    rescue ArgumentError => e
      raise MoveParseError.new(e.message)
    end

    unless move_squares.flatten.all? {|num| num.between?(0, 7) } &&
      move_squares.all? { |square| square.count == 2 }
      raise MoveParseError.new("All squares must be two digits between 1 and 7")
    end

    move_squares.each_index.map do |i|
      next if i == move_squares.size - 1
      [move_squares[i], move_squares[i + 1]]
    end.compact
  end
end


