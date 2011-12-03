class Enemy < Ball
  def initialize(window)
    super
    @image = Gosu::Image.new(window, "media/enemy.png", false)
    @radius = 10
    @mass = 10
    @accel = 0.3 # per tick
    @drag = 0.1 # per tick
    @velocity_max = 10
  end
end