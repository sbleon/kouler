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
    @window = window
  end

  def check_collision(other_ball)
    # Pythagorean theorem!
    distance = Math.sqrt((@x - other_ball.x)**2 + (@y - other_ball.y)**2)
    
    # If balls are closer than the sum of their radii, they must be touching
    if distance <= @radius + other_ball.radius
      collide(other_ball)
    end
  end

  # Calculate the new velocity components for this and the ball it has collided with
  def collide(other_ball)
    # puts "COLLISION between #{self} and #{other_ball}"

    # Calculate in a rotated frame of reference where the line between the
    # balls' centers is the x axis.
    # Math lifted from http://hoomanr.com/Demos/Elastic2/

    m1 = self.mass
    u1 = self.total_velocity
    d1 = self.current_angle
    m2 = other_ball.mass
    u2 = other_ball.total_velocity
    d2 = other_ball.current_angle

    # Collision angle (radians from vertical)
    a = Math.atan2(other_ball.x - self.x, self.y - other_ball.y)
    # puts "collision angle a = #{a}"

    # X/Y velocities in rotated frame
    v1_x = u1 * Math.cos(d1 - a)
    v1_y = u1 * Math.sin(d1 - a) * -1
    v2_x = u2 * Math.cos(d2 - a)
    v2_y = u2 * Math.sin(d2 - a) * -1

    # puts "v1_x = #{v1_x}"
    # puts "v1_y = #{v1_y}"
    # puts "v2_x = #{v2_x}"
    # puts "v2_y = #{v2_y}"

    # New X-velocities (Y-velocities do not change)
    f1_x = ((v1_x * (m1 - m2)) + (2 * m2 * v2_x)) / (m1 + m2)
    f2_x = ((v2_x * (m1 - m2)) + (2 * m1 * v1_x)) / (m1 + m2)
    # puts "f1_x = #{f1_x}"
    # puts "f2_x = #{f2_x}"

    # convert back to original frame of reference
    # New total velocity
    v1 = Math.sqrt(f1_x**2 + v1_y**2)
    v2 = Math.sqrt(f2_x**2 + v2_y**2)
    # puts "v1 = #{v1}"
    # puts "v2 = #{v2}"

    # New direction
    begin
      e1 = Math.atan2(f1_x, v1_y) + a
    rescue
      e1 = a
    end
    begin
      e2 = Math.atan2(f2_x, v2_y) + a
    rescue
      e2 = -1 * a
    end
    # puts "e1 = #{e1}"
    # puts "e2 = #{e2}"

    # New velocity components
    v1_x = v1 * Math.cos(e1) * -1
    v1_y = v1 * Math.sin(e1) * -1
    v2_x = v2 * Math.cos(e2) * -1
    v2_y = v2 * Math.sin(e2) * -1

    # puts "v1_x = #{v1_x}"
    # puts "v1_y = #{v1_y}"
    # puts "v2_x = #{v2_x}"
    # puts "v2_y = #{v2_y}"

    # Update objects' velocity components
    self.vel_x = v1_x
    self.vel_y = v1_y
    other_ball.vel_x = v2_x
    other_ball.vel_y = v2_y
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

  def draw
    unless @dead
      @image.draw_rot(@x, @y, ZOrder::Player, @angle)
      #display_velocity
    end
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

  def total_velocity
    Math.hypot(@vel_x, @vel_y)
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

  def display_velocity
    @window.draw_line(@x, @y, Gosu::white, @x + (10 * @vel_x), @y, Gosu::white, 100)
    @window.draw_line(@x, @y, Gosu::white, @x, @y + (10 * @vel_y), Gosu::white, 100)
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

  def touching_bounds
    return @x - @radius <= @bounds[:top_left][:x] || 
           @x + @radius >= @bounds[:bottom_right][:x] ||
           @y - @radius <= @bounds[:top_left][:y] ||
           @y + @radius >= @bounds[:bottom_right][:y]
  end

end