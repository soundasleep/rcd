class Explosion < TwoDimensionalObject
  def initialize(x, y)
    super(x, y)
    @age = 10
  end

  attr :age, true
end
