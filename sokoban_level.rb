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
  DIRECTIONS = {
    up:    UP,
    down:  DOWN,
    left:  LEFT,
    right: RIGHT
  }

  attr_reader :boxes, :player_pos, :history

  def self.from_file(filename)
    SokobanLevel.new.read_file(filename)
  end

  def initialize
    @history = []
  end

  def [](pos)
    @grid[pos.first][pos.last]
  end

  def read_file(filename)
    lines = File.readlines(filename).map(&:chomp)

    @boxes = []
    @goals = Set.new([])
    @grid = lines.each_with_index.map do
      |line, row| read_line(line, row)
    end

    setup_start
    self
  end

  def to_s
    @grid.each_with_index.collect do |row_squares, row|
      row_squares.each_with_index.collect do |square, col|
        pos = [row, col]

        case square
        when :wall then WALL
        when :floor then display_floor(square, pos)
        end
      end.join
    end.join("\n")
  end

  def move(direction)
    if can_move?(DIRECTIONS[direction])
      history << direction
      _move(DIRECTIONS[direction])
    end
  end

  def win?
    (@goals - @boxes).empty?
  end

  def restart
    @player = @player_start.dup
    @boxes = @boxes_start.map { |pos| pos.dup }
    @history = []
  end

  private
  def can_move?(delta)
    next_pos = pos_add(@player, delta)
    next_next_pos = pos_add(next_pos, delta)

    free?(next_pos) || self[next_pos] == :floor && free?(next_next_pos)
  end

  def _move(delta)
    pos_add!(@player, delta)

    box_idx = @boxes.index(@player)
    pos_add!(@boxes[box_idx], delta) if box_idx
  end

  def pos_add!(pos, delta)
    pos[0] += delta[0]
    pos[1] += delta[1]
  end

  def pos_add(pos, delta)
    [pos.first + delta.first, pos.last + delta.last]
  end

  def free?(pos)
    self[pos] == :floor && !@boxes.include?(pos)
  end

  def read_line(line, row)

    line.each_char.with_index.map do |square, col|
      pos = [row, col]
      @boxes << pos.dup if BOXES.include?(square)
      @player = pos if PLAYERS.include?(square)
      @goals << pos if GOALS.include?(square)

      square == WALL ? :wall : :floor
    end
  end

  def display_floor(square, pos)
    if @player == pos
      @goals.include?(pos) ? PLAYER_ON_GOAL : PLAYER
    elsif @boxes.include?(pos)
      @goals.include?(pos) ? BOX_ON_GOAL : BOX
    elsif @goals.include?(pos)
      GOAL
    else
      FLOOR
    end
  end

  def setup_start
    @player_start = @player.dup
    @player_start.freeze
    @boxes_start = @boxes.map { |pos| pos.dup.freeze }
    @boxes_start.freeze
  end
end
