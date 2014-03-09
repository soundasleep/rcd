class Player < TwoDimensionalObject
  def load(socket)
    bits = socket.gets.split(",")
    @x = bits[0].to_i
    @y = bits[1].to_i
  end

  def send(socket)
    socket.puts(@x.to_s + "," + @y.to_s)
  end

end
