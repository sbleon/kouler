require 'rubygems'
require 'gosu'

module ZOrder
  Background, Player = *0..1
end

class Player
  def initialize(window)
    @image = Gosu::Image.new(window, "media/player.png", false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Player, @angle)
  end

  def go(dir)
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

  def warp(x, y)
    @x, @y = x, y
  end

end

class GameWindow < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = "Kouler"
    
    @background_image = Gosu::Image.new(self, "media/space.png", true)
    
    @player = Player.new(self)
    @player.warp(320, 240)
  end

  def update
    @player.go :left if button_down? Gosu::KbLeft
    @player.go :right if button_down? Gosu::KbRight
    @player.go :down if button_down? Gosu::KbDown
    @player.go :up if button_down? Gosu::KbUp
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