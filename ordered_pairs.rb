module OrderedPairs
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
