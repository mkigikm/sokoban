require 'set'
require './sokoban_level'
require './maze_solver.rb'
require 'pqueue'
require 'byebug'

class SokoNode
  attr_reader :level, :move, :history

  def self.solve_from_file(filename)
    level = SokoLevel.from_file(filename)

    solve(level)
  end

  # future notes:
  # implement a "dead space" calculation that
  # 1. removes all boxes from the level
  # 2. for every square on the level
  #    1. puts a box there
  #    2. puts the player at adjacent spaces
  #    3. if the player cannot push the box to any goal from any space
  #       adds it to dead space where it knows to reject nodes that
  #       have a box in this space
  #
  # seperately can implement a "stuck" calculation that looks for
  # simple box formations that are unsolvable such as two boxes beside
  # each other on a wall that aren't on goals, 4 boxes in a square
  # formation not on goals, and boxes in corners not on goals
  #
  # more complicated stuck patterns I'm sure exist, but could be a
  # hard problem by themselves
  #
  # also, I'm not sure my move and undo method is any faster than
  # copying. will have to benchmark later, too bad I overwrote the
  # old one, but I could look at git history or just reimplement it,
  # it isn't that hard :)
  def initialize(level, history=[])
    @level = level
    @history = history
  end

  def children_or_win
    # first we apply the history to the current level
    apply_history

    # short circuit if we found the goal
    return :win if level.win?

    # future notes:
    # add nodes for any push moves
    # then add nodes that come from SokoMazeSolver

    # then we select the moves that can be applied from the
    # current position
    next_moves = SokoLevel::DELTAS.select do |dir|
      level.can_move?(dir)
    end

    # then we make a node for each of the possible moves
    children = next_moves.map do |dir|
      next_history = history.dup
      next_history << dir
      SokoNode.new(level, next_history)
    end

    # finally reset the level
    level.restart
    children
  end

  def push_children
    apply_history

    next_pushes = SokoLevel::DELTAS.select do |dir|
      level.can_push?(dir)
    end

    children = next_pushes.map do |push|
      level.move!(push)
      return [true, history + [push]] if level.win?
      level.undo!(push, true)

      SokoNode.new(level, history + [push])
    end

    level.restart
    [false, children]
  end

  def travel_children(visited)
    apply_history

    solver = SokoMazeSolver.new(level)
    #goal_count = solver.goals.count
    solver.goals.delete_if do |goal|
      visited.include?([goal, level.boxes].hash)
    end
    #pruned = goal_count - solver.goals.count
    #puts "pruned #{pruned}" if pruned > 0

    paths = solver.solve.map do |(goal, path)|
      visited << [goal, level.boxes].hash
      SokoNode.new(level, history + path)
    end

    level.restart
    paths
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

  # two nodes are hash equal iff
  # 1. their boxes are in the same position
  # 2. their players are at the same position
  # they may have taken different paths here, but we only care about
  # the one that came by a shorter path, which will be reflected by
  # the order the algorithm explores them
  def hash
    apply_history
    hash = [level.player, level.boxes].hash
    level.restart

    hash
  end

  def self.solve_pqueue(level)
    root = SokoNode.new(level)
    queue = PQueue.new([root]) do |x, y|
      y.history.count <=> x.history.count
    end
    visited = Set.new([[level.player, level.boxes].hash])
    max_depth = 0

    until queue.empty?
      cur = queue.pop
      #puts "depth=#{cur.history.count}"

      #debugger
      depth = cur.history.count
      if depth > max_depth
        #puts "Reached #{depth}"
        max_depth = depth
      end
      push_win, children = cur.push_children
      if push_win
        winning_moves = children
        break
      end

      children.concat(cur.travel_children(visited))

      children.each do |child|
        queue << child
        visited << child
      end
    end

    winning_moves.map { |delta| SokoLevel::DIRS.invert[delta] }
  end


  def self.solve(level)
    root = SokoNode.new(level)
    queue = [root]
    visited = Set.new([root])
    pruned = 0

    # future notes:
    # queue needs to be a priority queue that looks at
    # history.count. among those it could also have a heuristic
    # for calculating most promising node, but that's overkill
    # for now
    until queue.empty?
      current = queue.shift

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
