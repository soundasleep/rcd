class Monster < TwoDimensionalObject
  def wander(map)
    dx = rand(3) - 1
    dy = rand(3) - 1
    if !map.blocked(@x + dx, @y + dy)
      @x += dx
      @y += dy
    end
  end
end
