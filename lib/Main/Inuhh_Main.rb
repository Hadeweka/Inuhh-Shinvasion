# Player class.
class Inuhh < Entity
  attr_reader :dir, :stats, :collectibles, :boosts, :riding_entity, :drunken, :item, :item_amount, :vy, :invincible, :inv_inv
  
  def initialize(window, x, y, dir=nil)
      super()
      @x, @y = x, y
      @xsize = 20
      @ysize = 15
      @gxsize = 25
      @gysize = 25
      @drunken = false
      @collectibles = []
      @stats = []
      @boosts = []
      @riding = false
      @riding_entity = nil
      @inv_inv = 0 # Invisible invincibility
      @pushed_from_riding = 0
      @flying = false
      reset_stat(Stats::Score, 0)
      reset_stat(Stats::Strength, 1)
      reset_stat(Stats::Defense, 0)
      reset_stat(Stats::Speed, 0)
      reset_boost(Stats::Strength, 0, 0)
      reset_boost(Stats::Speed, 0, 0)
      reset_collectible(Objects::Coin, 0)
      reset_collectible(Objects::Gem, 0)
      reset_collectible(Objects::Shi_Coin, 0)
      reset_collectible(Objects::Fruit, 0)
      @dir = (dir ? (:right) : (:left))
      @invincible = 0
      @water_delay = 0
      @water_flag = false
      @water_boost = nil
      @combo = 0
      @item = nil
      @item_amount = 0
      @ice = false
      if Difficulty.get > Difficulty::NORMAL then
          reset_stat(Stats::Max_Lifes, 3)
          reset_stat(Stats::Max_Energy, 3)
      elsif Difficulty.get > Difficulty::EASY then
          reset_stat(Stats::Max_Lifes, 4)
          reset_stat(Stats::Max_Energy, 3)
      else
          reset_stat(Stats::Max_Lifes, 5)
          reset_stat(Stats::Max_Energy, 4)
      end
      full_heal
      @vy = 0 # Vertical velocity
      @vx = 0
      @jumping = 0
      @running = false
      @window = window
      @map = window.map
      # Load all animation frames
      reset_images
      # This always points to the frame that is currently drawn.
      # This is set in update, and used in draw.
      @cur_image = @standing
  end
  
  def reset_images
      if Time.now.month == 12 && [24, 25, 26].index(Time.now.day) then
          change_images("XMas")
      elsif (Time.now.month == 12 && Time.now.day == 31) || (Time.now.month == 1 && Time.now.day == 1) then
          change_images("Newyear")
      else
          @standing, @walk1, @walk2, @jump =
                  *Image.load_tiles(Pics::Inuhh, 2*@gxsize, 2*@gysize)
      end
  end
  
  def change_images(name)
      @standing, @walk1, @walk2, @jump =
              *Image.load_tiles(Pics::Folder_Forms + "#{name}.png", 2*@gxsize, 2*@gysize)
  end
  
  def delete_items
      @item = nil
      @item_amount = 0
      reset_images
  end

  def drop_item
      dropped_collectible = @item
      dropped_collectible.x = (@x/50).floor * 50 + 25
      dropped_collectible.y = (@y/50).floor * 50 + 50
      dropped_collectible.lock_collection
      dropped_collectible.modify_uses(@item_amount)

      @window.gems.push(dropped_collectible)
  end
  
  def set_item(collectible, amount)
      if @item
          drop_item
      end
      
      @item = collectible
      @item_amount = amount
      if @item.transform then
          change_images(@item.transform)
      else
          reset_images
      end
  end
  
  def add_item(collectible, amount)
      if !@item
          set_item(collectible, amount)
      elsif collectible.class != @item.class then
          set_item(collectible, amount)
      else
          @item_amount += amount
      end
  end
  
  def use_item
      return if !@item
      success = @item.use(@window, self)
      if success then
          @item_amount -= 1
          if @item_amount <= 0 then
              reset_images
              @item = nil
          end
      end
  end
  
  def in_air
      return false if @riding
      return @jumping > 0 || @vy != 0 || @flying
  end
  
  def shift_up(value)
      value.times do
          if @map.solid?(@x, @y-50) then
              damage(false)
          else
              @y -= 50
          end
      end
  end
  
  def update_timers
      @boosts.each do |b|
          if b then
              b[1] -= 1
              b[0] = 0 if b[1] < 0
              b[2] = 0 if b[1] < 0
          end
      end
  end
  
  def toggle_fly
      @flying = !@flying
  end
  
  def reset_collectible(nr, value)
      @collectibles[nr] = value
  end
  
  def reset_stat(nr, value)
      @stats[nr] = value
  end
  
  def reset_boost(nr, value, time)
      @boosts[nr] = [value, time]
  end
  
  def pay_shi_coins(value)
      @collectibles[Objects::Shi_Coin] -= value
  end
  
  def get_collectible(nr, amount)
      @collectibles[nr] += amount
  end
  
  def increase_stat(nr, amount)
      @stats[nr] += amount
      @stats[Stats::Energy] = [@stats[Stats::Max_Energy], @stats[Stats::Energy]].min
      if nr == Stats::Score && @window.minigame_flag then
          @window.increase_minigame_score(amount)
      end
  end
  
  def manipulate_energy(value)
      @stats[Stats::Energy] = value
  end
  
  def damage(value)
      if !value then
          @stats[Stats::Energy] = 0
          return
      end
      @stats[Stats::Energy] -= value
      if @stats[Stats::Energy] < 0 then
          @stats[Stats::Energy] = 0
      end
      if @stats[Stats::Energy] > 0 then
          if value > 0 then
              @window.play_sound("growl #{rand(4)+1}")
          else
              @window.play_sound("guard")
          end
      end
  end
  
  def lose_life
      @stats[Stats::Lifes] -= 1
  end
  
  def suicide
      @stats[Stats::Lifes] = 0
  end
  
  def boost(nr, amount, time)
      @boosts[nr] = [amount, time, time]
  end
  
  def preset(collectibles, stats)
      reset_stat(Stats::Score, stats[Stats::Score])
      reset_stat(Stats::Max_Energy, stats[Stats::Max_Energy])
      reset_stat(Stats::Max_Lifes, stats[Stats::Max_Lifes])
      reset_stat(Stats::Strength, stats[Stats::Strength])
      reset_stat(Stats::Defense, stats[Stats::Defense])
      reset_stat(Stats::Lifes, [stats[Stats::Lifes],stats[Stats::Max_Lifes]].max)
      reset_collectible(Objects::Coin, collectibles[Objects::Coin])
      reset_collectible(Objects::Gem, collectibles[Objects::Gem])
      reset_collectible(Objects::Shi_Coin, collectibles[Objects::Shi_Coin])
      reset_collectible(Objects::Fruit, collectibles[Objects::Fruit])
  end
  
  def new_map(map)
      @map = map
  end
  
  def draw
      # Flip vertically when facing to the left.
      if @dir == :left then
          offs_x = -25
          factor = 1.0
      else
          offs_x = 25
          factor = -1.0
      end
      @cur_image.draw(@x + offs_x, @y - 49, ZOrder::Player, factor, 1.0, (@drunken ? 0xff33ff66 : 0xffffffff)) if @invincible%2==0
      if @item then
          @item.draw_in_inventory(@window, self)
      end
  end
  
  # Could the object be placed at x + offs_x/y + offs_y without being stuck?
  def would_fit(offs_x, offs_y)
      return !@map.solid?(@x + offs_x + @xsize, @y + offs_y) && !@map.solid?(@x + offs_x + @xsize, @y + offs_y - 2*@ysize) && !@map.solid?(@x + offs_x - @xsize, @y + offs_y) && !@map.solid?(@x + offs_x - @xsize, @y + offs_y - 2*@ysize)
      # Check at the center/top and center/bottom for map collisions
  end
  
  def make_drunk(value)
      @drunken = value
  end
  
  def change_to_jump_img
      @cur_image = @jump
  end
  
  def update(move_x)
      @pushed_from_riding -= 1 if @pushed_from_riding > 0
      if @map.water(@x, @y) && !@water_flag && @water_delay <= 0 then
          @water_flag = true
          @water_delay = 10
          @window.play_sound("water")
      end
      if @map.poison(@x, @y) then
          @drunken = 10 if !@drunken
          @drunken += 2 if @drunken
          @drunken = 2000 if @drunken && @drunken > 2000
      elsif @map.water(@x, @y) && @drunken then
          @drunken -= 4
      end
      @water_delay -= 1
      update_timers
      if @drunken then
          move_x += (rand(15)-7)*(rand(4) == 0 ? 1 : 0)
          @drunken -= 1
          @drunken = false if @drunken <= 0
      end
      move_x /= (@water_boost ? 2.5/@water_boost : 2.5) if @map.water(@x, @y)
      move_x *= 2 if @running
      move_x *= (1.0+@boosts[Stats::Speed][0])
      move_x = move_x.to_i
      @invincible = [0, @invincible-1].max
      @inv_inv = 0
      # Select image depending on action
      if (move_x == 0)
          @cur_image = @standing
      else
          @cur_image = [@walk1, @walk2, @standing][(milliseconds / 175).floor % 3]
      end
      if (@vy < 0)
          @cur_image = @jump
      end
      if would_fit((@dir == :left ? -1 : 1),0) && (@map.ice(@x - @xsize, @y + 1) || @map.ice(@x + @xsize, @y + 1)) then
          @ice = true if !@ice
      else
          @ice = false
      end
      # Directional walking, horizontal movement
      move_x = (@dir == :left ? -5 : 5) if @ice
      if move_x > 0 then
          @dir = :right
          move_x.times { if would_fit(1, 0) then @x += 1 end }
      end
      if move_x < 0 then
          @dir = :left
          (-move_x).times { if would_fit(-1, 0) then @x -= 1 end }
      end
      # Acceleration/gravity
      # By adding 1 each frame, and (ideally) adding vy to y, the player's
      # jumping curve will be the parabole we want it to be.
      @vy += 1
      @vy = [@vy, 3].min if @map.water(@x, @y)
      @vx -= (@vx == 0 ? 0 : (@vx/@vx.abs).floor)
      # Vertical movement
      if @vy > 0 then
          @vy.to_i.times { if would_fit(0, 1) then @y += 1 else @vy = 0 end }
      end
      if @vy < 0 then
          (-@vy).to_i.times { if would_fit(0, -1) then @y -= 1 else @vy = 0 end }
      end
      if @vx > 0 then
          @vx.to_i.times { if would_fit(1, 0) then @x += 1 else @vx = 0 end }
      end
      if @vx < 0 then
          (-@vx).to_i.times { if would_fit(-1, 0) then @x -= 1 else @vx = 0 end }
      end
      if !would_fit(0, 0) then	# Kill Inuhh if stuck
          Debug.output("Stuck")
          damage(1000)
      end
      if @riding then
          spd = (@riding_entity.speed*(@riding_entity.dir == :right ? 1 : -1)).to_i
          grav = @riding_entity.vy.to_i
          if would_fit(0, @riding_entity.y - 2*@riding_entity.ysize + 5 - @y) then
              @y = @riding_entity.y - 2*@riding_entity.ysize + 5
          else
              @riding = false
              @riding_entity = nil
          end
          @y = @y.to_i
          if grav > 0 && @riding then
              grav.times { if would_fit(0, 1) then @y += 1 else  end }
          end
          if grav < 0 && @riding then
              (-grav).times { if would_fit(0, -1) then @y -= 1 else  end }
          end
          if spd > 0 && @riding then
              spd.times { if would_fit(1, 0) then @x += 1 else  end }
          end
          if spd < 0 && @riding then
              (-spd).times { if would_fit(-1, 0) then @x -= 1 else  end }
          end
          while @riding && (@x-@riding_entity.x).abs > 2*@riding_entity.xsize/3 && would_fit((@x-@riding_entity.x)/(@x-@riding_entity.x), 0) do
              @x -= (@x-@riding_entity.x)/(@x-@riding_entity.x).abs
          end
          if @riding && (@x-@riding_entity.x).abs > 2*@riding_entity.xsize/3 then
              @riding = false
              @riding_entity = nil
          end
          @vy = 0 if @riding
          if @riding && !(@riding_entity.living) then
              @riding = false
              @riding_entity = nil
          end
      end
      if @map.lethal(@x, @y) || @map.lethal(@x, @y - @ysize - 1) || @map.lethal(@x, @y + 1) || @map.lethal(@x + @xsize + 1, @y) || @map.lethal(@x - @xsize - 1, @y) then
          damage(1000)
      end
      cond_left = @map.lethal(@x - @xsize, @y + 1)
      cond_right = @map.lethal(@x + @xsize, @y + 1)
      cond_left_s = @map.solid?(@x - @xsize, @y + 1)
      cond_right_s = @map.solid?(@x + @xsize, @y + 1)
      if (cond_left && cond_right) then
          damage(1000)
      end
      if (cond_right && !cond_left_s) || (cond_left && !cond_right_s) then
          damage(1000)
      end
  end
  
  def run
      @running = true
  end
  
  def stop_running
      @running = false
  end
  
  def steal_coins(value)
      loss = [-value, -@collectibles[Objects::Coin]].max
      get_collectible(Objects::Coin, loss)
      @window.messages.push([loss.to_s + Strings::Coins, @x-25, @y, 100, true, 2.0, 2.0, 0xffff8800]) if loss < 0
      return -loss
  end
  
  def try_to_jump
      if @map.water(@x, @y) then
          if @map.water(@x, @y-5) && @water_delay <= 0 && @water_flag then
              @vy = -5
          elsif @water_delay <= 0 && @water_flag then
              @water_flag = false
              @water_delay = 10
              @vy = -12
              @window.play_sound("water")
          end
          @combo = 0
      elsif @map.solid?(@x - @xsize, @y + 1) || @map.solid?(@x + @xsize, @y + 1) || @flying || @riding then
          @jumping = 8
          @vy = -12 + (@riding ? @riding_entity.vy : 0)
          @combo = 0
      elsif @jumping > 0
          @vy -= 1
          @jumping -= 1
      end
      @riding = false
      @riding_entity = nil
  end
  
  def stop_jumping
      @jumping = 0
  end
  
  def knockback(strength)
      @vx = strength
      @pushed_from_riding = 10 if @riding
      @riding = false
      @riding_entity = nil
  end
  
  def check_projectiles(projectiles)
      projectiles.each do |p|
          if test_collision(p) && p.owner != Projectiles::INUHH && @invincible == 0 && @inv_inv == 0 then
              @invincible = 100
              defense = @stats[Stats::Defense]
              dv = [p.damage-defense+Projectiles::Inuhh_Plus[p.type], 0].max
              damage(dv)
              @x < p.x ? knockback(-10-(p.damage-1)) : knockback(10+(p.damage-1))
              @window.messages.push([dv, p.x+10, p.y-30, 20, true, 2.0+(dv-1)/10.0, 2.0+(dv-1)/10.0, 0xffff0000])
              p.break
          end
      end
  end
  
  def fly
      @flying = true
  end
  
  def collect_gems(gems)
      # Same as in the tutorial game.
      gems.reject! do |c|
          if (c.x - @x).abs < 2*@xsize && (c.y - @y + @ysize).abs < 2*@ysize
              c.collect(@window, self) unless c.locked?
              !c.constant && !c.locked?
          end
      end
      if @collectibles[Objects::Coin] >= 100 then
          @window.messages.push([Strings::One_Life, @x-25, @y-50, 100, true, 2.0, 2.0, 0xff0088ff])
          increase_stat(Stats::Lifes, 1)
          get_collectible(Objects::Coin, -100)
      end
      if @collectibles[Objects::Fruit] >= 3 then
          @window.messages.push(["+ 1", @x-25, @y, 100, true, 2.0, 2.0, 0xff0088ff])
          increase_stat(Stats::Energy, 1)
          get_collectible(Objects::Fruit, -3)
      end
  end
  
  def warp(warps)
      # Same as in the tutorial game.
      warps.each do |w|
          if (w.x - @x).abs < @xsize && (w.y - @y).abs < @ysize # Spheric hitbox maybe
              return w.destination
          end
      end
      return false
  end
  
  def kill(minigame_flag = false)
      if minigame_flag then
          manipulate_energy(1)
      else
          heal
          lose_life
      end
  end
  
  def set_water_boost(value)
      @water_boost = value
  end
  
  def heal
      reset_stat(Stats::Energy, @stats[Stats::Max_Energy])
  end
  
  def full_heal
      heal
      reset_stat(Stats::Lifes, @stats[Stats::Max_Lifes])
  end
  
  def reset_boosts
      @boosts.each do |b|
          if b then
              b[0] = 0
              b[1] = 0
              b[2] = 0
          end
      end
  end
  
  def reset(x, y, dir=nil, full_reset=true)
      @riding = false
      @drunken = false
      @x, @y = x, y
      @dir = (dir ? (:right) : (:left))
      @invincible = 0
      @inv_inv = 0
      @pushed_from_riding = 0
      @water_boost = nil
      @vy = 0
      @vx = 0
      if full_reset then
          @item = nil
          @item_amount = 0
          reset_boosts
          @flying = false
          reset_images
      end
      @combo = 0
      @cur_image = @standing
      @water_delay = 0
  end
  
  def test_collision(entity)
      return Collider::test_collision(self, entity)
      #return Collider::elliptic(@xsize, @ysize, entity.xsize, entity.ysize, @x-entity.x, @y-@ysize-entity.y+entity.ysize)
  end
  
  def damage_enemy(e)
      debug_plus = (@window.debug_strength_flag ? 99 : 0)
      damage_value = [0, @stats[Stats::Strength] + debug_plus + @boosts[Stats::Strength][0] - e.defense].max
      damage_value = [damage_value, e.reduction].min if e.reduction
      if e.riding then
          @riding = true if @vy > e.vy && @pushed_from_riding == 0
          @riding_entity = e if @vy > e.vy && @pushed_from_riding == 0
      elsif @pushed_from_riding == 0
          if e.invul == 0 then
              e.damage(damage_value)
              @vy = (@map.water(@x, @y)? -8 : -20)
              @jumping = 0
              #@window.sounds["jump"].play
              e.at_jumped_on
              @window.messages.push([damage_value, e.x-e.xsize+10, e.y-e.ysize-30, 20, true, 2.0+(damage_value-1)/30.0, 2.0+(damage_value-1)/30.0, 0xff00ff00])
          else
              @vy = (@map.water(@x, @y)? -8 : -20)
              @jumping = 0
          end
      end
      if !e.living then
          value = (@combo >= 10 ? e.score*100 : e.score*(@combo+1))
          score_size = (@combo >= 10 ? 3.0 : 2.0+(value/50000.0))
          score_color = (@combo >= 10 ? 0xff8888ff : 0xffffff00)
          @window.add_statistics(Statistics::Enemies_Jumped, 1)
          @window.messages.push([value, e.x-e.xsize, e.y-e.ysize, 100, true, score_size, score_size, score_color])
          increase_stat(Stats::Score, value)
          @combo += 1
          @inv_inv = 1
          @window.set_statistics(Statistics::Max_Combo, @combo) if @combo > @window.other_option_param(Other::Statistics, Statistics::Max_Combo, 0)
          @window.play_sound("smash", 1, [1+((@combo-1)*0.1),2].min) # The higher the combo, the higher the pitch... until maximum
          @window.residues.push(Residuum.new(e.x-e.xsize, e.y-2*e.ysize, 50, @window, e.mud))
      end
  end
  
  def spike_damage(e)
      if @invincible == 0 && @inv_inv == 0 || e.destiny then
          @invincible = 100
          e.at_collision
          defense = @stats[Stats::Defense]
          dv = [e.spike_strength-defense, 0].max
          dv = [dv, e.minsdamage].max if e.minsdamage
          damage(dv)
          @x < e.x ? knockback(-10-(e.strength-1+e.knockback)) : knockback(10+(e.strength-1+e.knockback))
          @window.messages.push([dv, e.x-e.xsize+10, e.y-e.ysize-30, 20, true, 2.0+(dv-1)/10.0, 2.0+(dv-1)/10.0, (dv == 666 ? 0xffaa0000 : 0xffff0000)])
      end
  end
  
  def normal_damage(e)
      @invincible = 100
      e.at_collision
      defense = @stats[Stats::Defense]
      dv = [e.strength-defense, 0].max
      dv = [dv, e.mindamage].max if e.mindamage
      damage(dv)
      @x < e.x ? knockback(-10-(e.strength-1+e.knockback)) : knockback(10+(e.strength-1+e.knockback))
      @window.messages.push([dv, e.x-e.xsize+10, e.y-e.ysize-30, 20, true, 2.0+(dv-1)/10.0, 2.0+(dv-1)/10.0, (dv == 666 ? 0xff660000 : 0xffff0000)])
  end
  
  def colliding(enemies)
      enemies.each do |e|
          next if e.transparent
          if !e.dangerous && test_collision(e) && e.z.abs < 10
              if @y-@ysize < e.y-e.ysize && would_fit(0, -1) then
                  if @vy-e.vy > 0 then
                      if !e.spike then
                          damage_enemy(e)
                      else
                          spike_damage(e)
                      end
                  elsif @riding && @invincible == 0 && @inv_inv == 0 && e != @riding_entity || e.destiny then
                      e.at_collision
                  elsif !@riding && @invincible == 0 && @inv_inv == 0 then
                      if @y < e.y - e.ysize then
                          if !e.spike then
                              damage_enemy(e)
                          else
                              spike_damage(e)
                          end
                      else
                          e.at_collision
                      end
                  end
              elsif @invincible == 0 && @inv_inv == 0 || e.destiny
                  e.at_collision
              end
          elsif test_collision(e) && e.z.abs < 10 then
              if @y-@ysize < e.y-e.ysize && would_fit(0, -1) then
                  if @vy-e.vy > 0 then
                      if !e.spike then
                          damage_enemy(e)
                      else
                          spike_damage(e)
                      end
                  elsif @riding && @invincible == 0 && @inv_inv == 0 && e != @riding_entity || e.destiny then
                      normal_damage(e)
                  elsif !@riding && @invincible == 0 && @inv_inv == 0 then
                      if @y < e.y - e.ysize then
                          if !e.spike then
                              damage_enemy(e)
                          else
                              spike_damage(e)
                          end
                      else
                          normal_damage(e)
                      end
                  end
              elsif @invincible == 0 && @inv_inv == 0 || e.destiny
                  normal_damage(e)
              end
          end
      end
  end
  
end