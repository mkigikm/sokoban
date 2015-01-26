require 'set'

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
  UP    = [-1,  0]
  DOWN  = [ 1,  0]
  LEFT  = [ 0, -1]
  RIGHT = [ 0,  1]
  DELTAS = [UP, DOWN, LEFT, RIGHT]

  attr_reader :boxes, :player_pos

  def self.from_file(filename)
    SokobanLevel.new.read_file(filename)
  end

  def ==(level)
    return false unless level.is_a?(self.class)
    @player_pos == level.player_pos && @boxes == level.boxes
  end

  def eql?(level)
    self == level
  end

  def hash
    [@player_pos, @boxes].hash
  end

  def initialize(grid=nil, player_pos=nil, goals=nil, boxes=nil)
    @grid = grid
    @player_pos = player_pos
    @goals = goals
    @boxes = boxes
  end

  def [](pos)
    @grid[pos.first][pos.last]
  end

  def read_file(filename)
    lines = File.readlines(filename).map(&:chomp)

    @boxes = Set.new([])
    @goals = Set.new([])
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

  def up
    safe_move(UP)
  end

  def up?
    can_move?(UP)
  end

  def down
    safe_move(DOWN)
  end

  def down?
    can_move?(DOWN)
  end

  def left
    safe_move(LEFT)
  end

  def left?
    can_move?(LEFT)
  end

  def right
    safe_move(RIGHT)
  end

  def right?
    can_move?(RIGHT)
  end

  def dup
    SokobanLevel.new(@grid.dup, @player_pos.dup, @goals.dup, @boxes.dup)
  end

  def win?
    (@goals - @boxes).empty?
  end

  private
  def can_move?(delta)
    next_pos = pos_add(@player_pos, delta)
    next_next_pos = pos_add(next_pos, delta)

    free?(next_pos) || (passable?(next_pos) && free?(next_next_pos))
  end

  def safe_move(delta)
    move(delta) if can_move?(delta)
  end

  def move(delta)
    next_pos = pos_add(@player_pos, delta)
    next_next_pos = pos_add(next_pos, delta)

    @player_pos = next_pos
    if @boxes.include?(next_pos)
      @boxes.delete(next_pos)
      @boxes << next_next_pos
    end
  end

  def pos_add(pos, delta)
    [pos.first + delta.first, pos.last + delta.last]
  end

  def free?(pos)
    passable?(pos) && !@boxes.include?(pos)
  end

  def passable?(pos)
    self[pos] == :floor || self[pos] == :goal
  end

  def read_line(line, row)

    line.each_char.with_index.map do |square, col|
      pos = [row, col]
      @boxes << pos if BOXES.include?(square)
      @player_pos = pos if PLAYERS.include?(square)

      if square == WALL
        :wall
      elsif GOALS.include?(square)
        @goals << pos
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
