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

  def read_file(filename)
    lines = File.readlines(filename).map(&:chomp)

    @boxes = []
    @grid = lines.each_with_index.map { |line, row| read_line(line, row) }
  end

  def to_s
    @grid.collect do |row|
      row.collect do |square|
        case square
        when :wall then WALL
        when :goal then GOAL
        when :floor then FLOOR
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
end
