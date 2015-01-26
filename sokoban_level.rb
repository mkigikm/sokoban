class SokobanLevel
  BOX = "$"
  PLAYER = "@"
  PLAYER_ON_GOAL = "+"
  WALL = "#"
  GOAL ="."
  BOX_ON_GOAL = "*"
  FLOOR = " "
  PASSABLE_ELEMENTS = [BOX, PLAYER, PLAYER_ON_GOAL, GOAL, FLOOR]
  GOALS = [GOAL, PLAYER_ON_GOAL, BOX_ON_GOAL]
  PLAYERS = [PLAYER, PLAYER_ON_GOAL]
  BOXES = [BOX, BOX_ON_GOAL]

  def self.from_file(filename)
    SokobanLevel.new.read_file(filename)
  end

  def read_file(filename)
    lines = File.readlines(filename).map(&:chomp)

    @boxes = []
    @grid = lines.each_with_index.map { |line, row| read_line(line, row) }

    self
  end

  def to_s
    @grid.each_with_index.collect do |row_squares, row|
      row_squares.each_with_index.collect do |square, col|
        pos = [row, col]

        case square
        when :wall then WALL
        when :goal then display_goal(square, pos)
        when :floor then display_floor(square, pos)
        end
      end.join
    end.join("\n")
  end

  private
  def read_line(line, row)

    line.each_char.with_index.map do |square, col|
      pos = [row, col]
      @boxes << pos if BOXES.include?(square)
      @player_pos = pos if PLAYERS.include?(square)

      if square == WALL
        :wall
      elsif GOALS.include?(square)
        :goal
      else
        :floor
      end
    end
  end

  def display_goal(square, pos)
    if @player_pos == pos
      PLAYER_ON_GOAL
    elsif @boxes.include?(pos)
      BOX_ON_GOAL
    else
      GOAL
    end
  end

  def display_floor(square, pos)
    if @player_pos == pos
      PLAYER
    elsif @boxes.include?(pos)
      BOX
    else
      FLOOR
    end
  end
end
