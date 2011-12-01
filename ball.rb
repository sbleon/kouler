class Ball
  # A ball needs to be able to check if another is close enough to collide
  attr_reader :x, :y, :radius
  # Need to be able to calculate the results of a collision
  attr_reader :mass
  # Need to be able to change the velocity if something else hits this
  attr_accessor :vel_x, :vel_y

  def initialize(window)
    super
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @dead = false
    @radius = 1
    @mass = 1
    @accel = 0.3 # per tick
    @drag = 0.1 # per tick
    @velocity_max = 10
    @bounds = {
      :top_left => {:x => 0, :y => 0},
      :bottom_right => {:x => window.width, :y => window.height}
    }
  end

  def check_collision(other_ball)
    # Pythagorean theorem!
    distance = Math.sqrt((@x - other_ball.x)**2 + (@y - other_ball.y)**2)
    
    # If balls are closer than the sum of their radii, they must be touching
    if distance <= @radius + other_ball.radius
      collide(other_ball)
    end
  end

  # Calculate the new velocity for this and the ball it has collided with
  def collide(other_ball)
    # Stupid collision for now
    @vel_x *= -1
    @vel_y *= -1
    other_ball.vel_x *= -1
    other_ball.vel_y *= -1
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Player, @angle)
  end

  def thrust(angle)
    if @dead
      return
    end

    # Face the direction of thrust
    @angle = angle
    radians = angle * Math::PI / 180

    # Accelerate
    @vel_x += @accel * Math.sin(radians)
    @vel_y += -1 * @accel * Math.cos(radians)
  end

  def update
    unless @dead
      move
      check_for_death
      slow_down
      cap_velocity
    end
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def warp_random
    @x = rand * @bounds[:bottom_right][:x]
    @y = rand * @bounds[:bottom_right][:y]
  end

  #####################
  protected
  #####################

  def cap_velocity
    while total_velocity > @velocity_max do
      slow_down
    end
  end

  def check_for_death
    if touching_bounds
      @dead = true
    end
  end

  # Returns angle of motion between -PI and +PI, with 0 being up.
  def current_angle
    vx = (@vel_x.abs < 0.001) ? 0 : @vel_x
    vy = (@vel_y.abs < 0.001) ? 0 : @vel_y

    if (vx == 0) && (vy == 0)
      0
    else
      Math.atan2(vx, -1 * vy)
    end
  end

  def move
    @x = @x + @vel_x
    @y = @y + @vel_y
  end

  def slow_down
    angle = current_angle

    drag_x = Math.sin(angle) * @drag
    drag_y = -1 * Math.cos(angle) * @drag

    if @vel_x > 0
      @vel_x -= drag_x
      @vel_x = 0 if @vel_x < 0
    elsif @vel_x < 0
      @vel_x -= drag_x
      @vel_x = 0 if @vel_x > 0
    end
    if @vel_y > 0
      @vel_y -= drag_y
      @vel_y = 0 if @vel_y < 0
    elsif @vel_y < 0
      @vel_y -= drag_y
      @vel_y = 0 if @vel_y > 0
    end
  end

  def total_velocity
    Math.hypot(@vel_x, @vel_y)
  end

  def touching_bounds
    return @x - @radius <= @bounds[:top_left][:x] || 
           @x + @radius >= @bounds[:bottom_right][:x] ||
           @y - @radius <= @bounds[:top_left][:y] ||
           @y + @radius >= @bounds[:bottom_right][:y]
  end

end