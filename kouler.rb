require 'rubygems'
require 'gosu'
load 'ball.rb'
load 'enemy.rb'
load 'player.rb'

module ZOrder
  Background, Player = *0..1
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

    # Check for collisions
    collisions_checked = []
    @enemies.each do |enemy|
      enemy.chase(@player)

      # We don't want to ever check for a collision between something and itself, so pretend
      # we already did it.
      collisions_checked << [enemy, enemy]
      # Check each other enemy
      @enemies.each do |other_enemy|
        # unless we've already checked these two
        unless collisions_checked.include?([other_enemy, enemy])
          enemy.check_collision(other_enemy)
          collisions_checked << [enemy, other_enemy]
        end
      end
      # Check the player
      enemy.check_collision(@player)
    end

    # Update position, velocity, dead-ness state, etc
    @player.update
    @enemies.map(&:update)
  end

  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    @player.draw
    @enemies.map(&:draw)
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
    if id == Gosu::KbSpace then
      restart
    end
  end

  def start
    @player = Player.new(self)
    @player.warp(@width / 2, @height / 2)

    @enemies = []
    3.times do
      @enemies << e = Enemy.new(self)
      e.warp_random
    end
  end

  def restart
    @player = nil if @player
    @enemies = nil if @enemies
    start
  end
end

window = GameWindow.new
window.show