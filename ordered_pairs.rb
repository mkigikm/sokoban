module OrderedPairs
  UP    = [-1,  0]
  DOWN  = [ 1,  0]
  LEFT  = [ 0, -1]
  RIGHT = [ 0,  1]
  DELTAS = [UP, DOWN, LEFT, RIGHT]
  DIRS = {
    up:    UP,
    down:  DOWN,
    left:  LEFT,
    right: RIGHT
  }

  def pos_add!(pos, delta)
    pos[0] += delta[0]
    pos[1] += delta[1]
  end

  def pos_add(pos, delta)
    [pos.first + delta.first, pos.last + delta.last]
  end

  def pos_sub(pos, delta)
    [pos.first - delta.first, pos.last - delta.last]
  end

  def pos_sub!(pos, delta)
    pos[0] -= delta[0]
    pos[1] -= delta[1]
  end
end
