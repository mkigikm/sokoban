require 'set'
require './sokoban_level'
require './maze_solver.rb'

class SokoNode
  include MazeSolver

  attr_reader :level, :move, :depth, :history

  def self.solve_from_file(filename)
    level = SokoLevel.from_file(filename)

    solve(level)
  end

  def initialize(level, history=[], depth=0)
    @level = level
    @history = history
    @depth = depth
  end

  def children_or_win
    # first we apply the history to the current level
    apply_history

    # short circuit if we found the goal
    return :win if level.win?

    # then we select the moves that can be applied from the
    # current position
    next_moves = SokoLevel::DELTAS.select do |dir|
      level.can_move?(dir)
    end

    # then we make a node for each of the possible moves
    children = next_moves.map do |dir|
      next_history = history.dup
      next_history << dir
      SokoNode.new(level, next_history, depth + 1)
    end

    # finally reset the level
    level.restart
    children
  end

  def apply_history
    history.each { |dir| level.move!(dir) }
  end

  # two nodes are equal if after applying all the moves the boxes
  # and player are in the same positions
  def ==(node)
    return false unless node.is_a?(SokoNode)

    hash == node.hash
  end

  def eql?(node)
    self == node
  end

  def hash
    apply_history
    hash = [level.player, level.boxes].hash
    level.restart

    hash
  end

  def self.solve(level)
    root = SokoNode.new(level)
    queue = [root]
    visited = Set.new([root])
    depths = Set.new
    pruned = 0

    until queue.empty?
      current = queue.shift

      unless depths.include?(current.depth)
        puts "Reached depth #{current.depth}"
        depths << current.depth
      end

      children = current.children_or_win
      break if children == :win

      children.each do |child|
        if !visited.include?(child)
          queue << child
          visited << child
        # else
        #   pruned += 1
        #   puts "Pruned #{pruned}" if pruned % 10000 == 0
        end
      end

      #puts "visted #{visited.count}" if visited.count % 10000 == 0
    end

    # puts "pruned #{pruned}"
    current.history.map { |move| SokoLevel::DIRS.invert[move] }
  end
end
