class Player < Monster
  def load(socket)
    bits = socket.gets.split(",")
    @x = bits[0].to_i
    @y = bits[1].to_i
    @name = bits[2]
  end

  def send(socket)
    socket.puts(@x.to_s + "," + @y.to_s + "," + @name)
  end

  def initialize(x, y, name)
    super(x, y)
    @name = name
  end

  attr :name, true
end
