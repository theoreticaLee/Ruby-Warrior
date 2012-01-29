require 'ap'

class Player
  MAX_HEALTH = 20
  SAFE_MID_HEALTH = 16
  SAFE_MIN_HEALTH = 8
  
  def initialize
    @previous_warrior_health = MAX_HEALTH
  end
  
  def play_turn(warrior)
    @warrior = warrior
    attacked = attacked?


    if enemy_visible?
      warrior.shoot!(enemy_direction)
    elsif walking_into_wall?
      @warrior.pivot!(:backward)
    elsif feel_captive?
      @warrior.rescue!(captive_direction)
    elsif captive_visible_afar?
        warrior.walk!(captive_direction)
    elsif safe?(attacked) && healthy? == false
      @warrior.rest!
    elsif retreat?(attacked)
      retreat!
    elsif @warrior.feel(:forward).empty?
    	@warrior.walk!
    else
    	@warrior.attack!
    end
  end
  
  def enemy_visible?
    enemy_direction != nil
  end
  def enemy_direction
    [:backward, :forward].each do |dir|
        shot_obstructed = false
        @warrior.look(dir).each do |x|
          shot_obstructed = true if x.captive?

          return dir if x.enemy? && shot_obstructed == false 
        end 
     end
     return nil
  end


  def retreat!
    	@warrior.walk!(:backward)
  end
  def retreated?
    @warrior.feel(:backward).empty? == false
  end
  def retreat?(attacked)
    attacked == true && @warrior.health <= SAFE_MIN_HEALTH && retreated? == false
  end

  def healthy?
    @warrior.health == MAX_HEALTH
  end
  
  def safe? (attacked)
    directForwardSafe = @warrior.feel(:forward).empty? || @warrior.feel(:forward).wall?
    directBackwardSafe = @warrior.feel(:backward).empty? || @warrior.feel(:backward).wall?

    attacked == false && directForwardSafe && directForwardSafe
  end
  
  def attacked?
    feeling_worse = @previous_warrior_health > @warrior.health
    @previous_warrior_health = @warrior.health
    feeling_worse
  end


  def feel_captive?
    feel_captive_direction != nil
  end
  def feel_captive_direction
    [:forward, :backward, :left, :right].each do |dir|
  		return dir if @warrior.feel(dir).captive?
  	end
  	return nil
  end
  
  def walking_into_wall?
    @warrior.feel(:forward).wall?
  end
  
  def captive_visible_afar?
    captive_direction != nil
  end
  
  def captive_direction
     [:backward, :forward].each do |dir|
        @warrior.look(dir).each do |x|
          return dir if x.captive?
        end 
     end
     return nil
  end
  
end
