require 'rubygems'
require 'gosu'

module ZOrder
  Background, Player = *0..1
end

class Player
  def initialize(window)
    @image = Gosu::Image.new(window, "media/player.png", false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @dead = false
    @radius = 24
    @accel = 0.3 # per tick
    @drag = 0.1 # per tick
    @velocity_max = 4
    @bounds = {
      :top_left => {:x => 0, :y => 0},
      :bottom_right => {:x => window.width, :y => window.height}
    }
  end

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

  def draw
    @image.draw_rot(@x, @y, ZOrder::Player, @angle)
  end

  def move
    @x = @x + @vel_x
    @y = @y + @vel_y
  end

  def thrust(angle)
    # Face the direction of thrust
    @angle = angle
    radians = angle * Math::PI / 180

    # Accelerate
    @vel_x += @accel * Math.sin(radians)
    @vel_y += -1 * @accel * Math.cos(radians)
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

end

class GameWindow < Gosu::Window
  attr_reader :height, :width

  def initialize
    @height = 600
    @width = 800
    super(@width, @height, false)
    self.caption = "Kouler"
    
    @background_image = Gosu::Image.new(self, "media/space.png", true)

    @buttons = []
    @buttons[0] = [Gosu::KbUp, Gosu::KbRight, Gosu::KbDown, Gosu::KbLeft]
    @buttons[1] = [Gosu::KbW, Gosu::KbD, Gosu::KbS, Gosu::KbA]

    start
  end

  def update
    if (player_button_dir = button_dir(0))
      @player.thrust(player_button_dir)
    end

    @player.update
  end

  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    @player.draw
  end

  def button_dir(player_num)
    dir = if button_down?(@buttons[player_num][0]) && button_down?(@buttons[player_num][1]); 45
       elsif button_down?(@buttons[player_num][1]) && button_down?(@buttons[player_num][2]); 135
       elsif button_down?(@buttons[player_num][2]) && button_down?(@buttons[player_num][3]); 225
       elsif button_down?(@buttons[player_num][3]) && button_down?(@buttons[player_num][0]); 315
       elsif button_down?(@buttons[player_num][0]);   0
       elsif button_down?(@buttons[player_num][1]);  90
       elsif button_down?(@buttons[player_num][2]); 180
       elsif button_down?(@buttons[player_num][3]); 270
       end
  end

  def button_down(id)
    if id == Gosu::KbEscape then
      close
    end
    if id == Gosu::KbS then
      restart
    end
  end

  def start
    @player = Player.new(self)
    @player.warp(@width / 2, @height / 2)
  end

  def restart
    @player = nil if @player
    start
  end
end

window = GameWindow.new
window.show