require 'ap'
class Player
  MAX_HEALTH = 20
  DIRS = [:forward, :backward, :left, :right]
  
  def play_turn(warrior)
    @warrior = warrior
    
    listen!
    action!
  end
  
  def action!

    if multiple_attacking_enemies?
      @warrior.bind!(feel_enemy_directions.first)
    elsif emergency_captive_extraction?
      emergency_orders!
    elsif feel_enemy?
      @warrior.attack!(feel_enemy_directions.first)
    elsif !healthy?
      @warrior.rest!
    elsif feel_captive?
      @warrior.rescue!(feel_captive_directions.first)
    else
      walk!
    end
    
  end
  
  #builds @captives_direction/@enemies_direction/@bombs_direction arrays
  def listen!
    @captives_direction = []
    @enemies_direction = []
    @bombs_direction = []
    
    @warrior.listen.each do  |unit|
        @captives_direction << @warrior.direction_of(unit) if unit.captive?
        @enemies_direction << @warrior.direction_of(unit) if unit.enemy?
        @bombs_direction << @warrior.direction_of(unit) if unit.ticking?
    end

  end
  
  def captives_around?
    !@captives_direction.empty?
  end
  def enemies_around?
    !@enemies_direction.empty?
  end
  
  def feel_escape?
    !feel_escape_directions.empty?
  end
  def feel_escape_directions
    DIRS.map { |dir| @warrior.feel(dir).empty? ? dir : nil }.compact
  end
  
  def multiple_attacking_enemies?
    feel_enemy_directions.length > 1
  end
  
  def healthy?
    @warrior.health == MAX_HEALTH
  end
  
  def feel_enemy?
    res = feel_enemy_directions.length > 0
    ap 'felt enemy(s) ' + feel_enemy_directions.join(', ')  if res
    res
  end
  def feel_enemy_directions
    DIRS.map { |dir| 
      @warrior.feel(dir).enemy? ? dir : nil 
    }.compact
  end
  
  def feel_captive?
    !feel_captive_directions.empty?
  end
  def feel_captive_directions
    DIRS.map { |dir| @warrior.feel(dir).captive? ? dir : nil }.compact
  end
  
  def walk!
    # if walking_orders == :backward
    #   @warrior.pivot! 
    # else
      @warrior.walk!(walking_orders)
    # end
  end
  def walking_orders
    
    if enemies_around?
      walk_around_stairs(@enemies_direction.first)
    elsif captives_around?
      walk_around_stairs(@captives_direction.first)
    else
      @warrior.direction_of_stairs
    end
    
  end
  def walk_around_stairs(dir)

    # alter direction if we feel stairs
    if @warrior.feel(dir).stairs?
      DIRS.each do |altDir| 
        if @warrior.feel(altDir).stairs? == false && @warrior.feel(altDir).wall? == false
          return altDir 
        end
      end
    end
    
    dir
  end

  def emergency_captive_extraction?
    @bombs_direction.length > 0 && @captives_direction.length > 0
  end
  def emergency_orders!

    if feel_captive?
      @warrior.rescue!(feel_captive_directions.first)
    elsif @warrior.feel(@captives_direction.first).empty?
      @warrior.walk!(@captives_direction.first)
    else
      @warrior.walk!(alternate_directions(@captives_direction.first).first)
    end
  end
  
  def alternate_directions (dir)
    #grrr
    dirs = DIRS.dup
    # remove backward
    dirs.delete(:backward)
    dirs.map { |altDir| 
      @warrior.feel(altDir).empty? && altDir != dir ? altDir : nil 
    }.compact
  end
  
end
