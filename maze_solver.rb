require 'set'
require './ordered_pairs'

class SokoMazeSolver
  include OrderedPairs

  attr_reader :goals

  def initialize(level)
    @level = level
    @start = level.player

    goals = level.boxes.collect_concat do |box|
      adjacents(box)
    end
    goals.delete_if { |pos| blocked?(pos) }
    @goals = Set.new(goals)

    @paths, @queue, @visited = [], [@start], Set.new([@start])
    @parents, @move_to = {@start => nil}, {@start => nil}
  end

  def adjacents(pos)
    DELTAS.collect do |delta|
      pos_add(pos, delta)
    end
  end

  def blocked?(pos)
    @level[pos] == :wall || @level.boxes.include?(pos)
  end

  def solve
    until @queue.empty? || @goals.empty?
      cur = @queue.shift

      adjacents(cur).zip(DELTAS).each do |pos, delta|
        unless blocked?(pos) || @visited.include?(pos)
          explore(cur, pos, delta)
        end
      end
    end

    @paths
  end

  def explore(cur, pos, delta)
    @visited << pos
    @queue << pos
    @parents[pos] = cur
    @move_to[pos] = delta

    # if its a goal, remove it from goals and add the path to it
    if @goals.include?(pos)
      @paths << path_to(pos)
      @goals.delete(pos)
    end
  end

  def path_to(pos)
    path = []

    until pos == @start
      path.unshift(@move_to[pos])
      pos = @parents[pos]
    end

    [pos, path]
  end
end
