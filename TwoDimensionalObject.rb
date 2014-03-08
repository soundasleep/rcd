# something simply with an (x,y)
class TwoDimensionalObject
  def initialize(x, y)
    @x = x
    @y = y
  end

  attr :x, true
  attr :y, true

  # equivalent to:
  # def x
  #   @x
  # end
  # def y
  #   @y
  # end
  # def x=(a)
  #   @x=a
  # end
  # def y=(a)
  #   @y=a
  # end
end
