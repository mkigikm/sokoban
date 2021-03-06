require 'set'
require_relative 'ordered_pairs'

class SokoLevel
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

  include OrderedPairs

  attr_reader :boxes, :player, :history

  def self.from_file(filename)
    SokoLevel.new.read_file(filename)
  end

  def initialize(player=nil, boxes=nil, history=[], grid=nil,
      player_start=nil, boxes_start=nil, goals=nil)
    @player, @boxes, @history, @grid = player, boxes, history, grid
    @player_start, @boxes_start, @goals = player_start, boxes_start, goals
  end

  def [](pos)
    @grid[pos.first][pos.last]
  end

  def size
    [@grid.count, @grid.first.count]
  end

  def read_file(filename)
    lines = File.readlines(filename).map(&:chomp)

    @boxes = []
    @goals = Set.new([])
    @grid = lines.each_with_index.map do |line, row|
      read_line(line, row)
    end

    setup_start
    self
  end

  # needs to copy @player, @boxes, @history
  # can pass @grid, @player_start, @boxes_start, @goals
  def dup
    SokoLevel.new(@player.dup, @boxes.map { |box| box.dup }, @history.dup,
      @grid, @player_start, @boxes_start, @goals)
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

  def dup
  end

  def inspect
    "\n#{to_s}"
  end

  def can_move?(delta)
    next_pos = pos_add(@player, delta)
    next_next_pos = pos_add(next_pos, delta)

    free?(next_pos) ||
      self[next_pos] == :floor && free?(next_next_pos)
  end

  def can_push?(delta)
    next_pos = pos_add(@player, delta)
    next_next_pos = pos_add(next_pos, delta)

    @boxes.include?(next_pos) && free?(next_next_pos)
  end

  def move(dir)
    if can_move?(DIRS[dir])
      undo_push = move!(DIRS[dir])
      history << [dir, undo_push]
      true
    else
      false
    end
  end

  def move!(delta)
    pos_add!(@player, delta)

    box_idx = @boxes.index(@player)
    pos_add!(@boxes[box_idx], delta) if box_idx

    !box_idx.nil?
  end

  def undo
    if !history.empty?
      dir, undo_push = history.pop
      undo!(DIRS[dir], undo_push)
      true
    else
      false
    end
  end

  def undo!(delta, undo_push)
    if undo_push
      box_idx = @boxes.index(pos_add(@player, delta))
      pos_sub!(@boxes[box_idx], delta)
    end

    pos_sub!(@player, delta)
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
