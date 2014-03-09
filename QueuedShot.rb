class QueuedShot < TwoDimensionalObject
  def initialize(x, y, dx, dy)
    super(x, y)
    @dx = dx
    @dy = dy
  end

  attr :dx, true
  attr :dy, true
end
