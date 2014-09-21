class Enemy < Ball

  attr_accessor :target_dx, :target_dy

  def initialize(window)
    super
    @image = Gosu::Image.new(window, "media/enemy.png", false)
    @radius = 10
    @mass = 25
    @accel = 0.4 # per tick
    @drag = 0.1 # per tick
    @velocity_max = 6
  end

  def chase(ball)
    dx = ball.x - @x
    dy = @y - ball.y # Backwards because of inverted Y axis
    direction_to = Math.atan2(dx, dy) * 180 / Math::PI

    thrust(direction_to)

    @target_dx = dx
    @target_dy = dy
  end

  def draw
    super
    # unless @dead
    #   @window.draw_line(@x, @y, Gosu::Color::YELLOW, @x + (@target_dx), @y - (@target_dy), Gosu::Color::YELLOW, 100)
    # end
  end
end