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
    @bounds = {
      :top_left => {:x => 0, :y => 0},
      :bottom_right => {:x => window.width, :y => window.height}
    }
  end

  def check_for_death
    if touching_bounds
      @dead = true
    end
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Player, @angle)
  end

  def go(dir)
    if @dead
      return
    end

    case dir
      when :left
        @x = @x - 3
        @angle = 270
      when :right
        @x = @x + 3
        @angle = 90
      when :up
        @y = @y - 3
        @angle = 0
      when :down
        @y = @y + 3
        @angle = 180
    end
  end

  def touching_bounds
    return @x <= @bounds[:top_left][:x] || 
           @x >= @bounds[:bottom_right][:x] ||
           @y <= @bounds[:top_left][:y] ||
           @y >= @bounds[:bottom_right][:y]
  end

  def warp(x, y)
    @x, @y = x, y
  end

end

class GameWindow < Gosu::Window
  attr_reader :height, :width

  def initialize
    @height = 480
    @width = 640
    super(@width, @height, false)
    self.caption = "Kouler"
    
    @background_image = Gosu::Image.new(self, "media/space.png", true)
    
    @player = Player.new(self)
    @player.warp(@width / 2, @height / 2)
  end

  def update
    @player.go :left if button_down? Gosu::KbLeft
    @player.go :right if button_down? Gosu::KbRight
    @player.go :down if button_down? Gosu::KbDown
    @player.go :up if button_down? Gosu::KbUp
    @player.check_for_death
  end

  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    @player.draw
  end

  def button_down(id)
    if id == Gosu::KbEscape then
      close
    end
  end
end

window = GameWindow.new
window.show