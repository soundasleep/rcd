class Explosion < TwoDimensionalObject
  def initialize(x, y)
    super(x, y)
    @age = 5
  end

  attr :age, true
end
