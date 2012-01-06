class Player < Ball
  def initialize(window)
    super
    @image = Gosu::Image.new(window, "media/player.png", false)
    @radius = 24
    @mass = 80
    @accel = 0.3 # per tick
    @drag = 0.1 # per tick
    @velocity_max = 5
  end
end