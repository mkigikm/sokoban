require 'set'
require './sokoban_level'

class SokobanNode
  attr_reader :level, :move, :depth

  def initialize(level, move=nil, depth=0)
    @level = level
    @move = move
    @depth = depth
  end

  def children
    moves = [:up?, :down?, :left?, :right?].zip([:up, :down, :left, :right])

    moves.select! { |direction| @level.send(direction.first) }
    moves.map do |direction|
      new_level = @level.dup
      new_level.send(direction.last)
      SokobanNode.new(new_level, direction.last, depth + 1)
    end
  end

  def self.solve_from_file(filename)
    level = SokobanLevel.from_file(filename)

    solve(level)
  end

  def self.solve(level)
    root = SokobanNode.new(level)
    queue = [root]
    visited = Set.new([level])
    parents = {}
    depths = Set.new
    pruned = 0

    until queue.empty?
      current = queue.shift
      unless depths.include?(current.depth)
        puts "Reached depth #{current.depth}"
        depths << current.depth
      end
      break if current.level.win?
      current.children.each do |child|
        if !visited.include?(child.level)
          queue << child
          parents[child] = current
          visited << child.level
        else
          pruned += 1
        end
      end
    end

    puts "pruned #{pruned}"

    moves = []
    until current == root
      moves << current.move
      current = parents[current]
    end

    moves.reverse
  end
end
