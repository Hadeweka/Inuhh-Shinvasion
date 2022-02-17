$LOAD_PATH << "."

require 'rubygems'
require 'gosu'

include Gosu

EDITOR = false
SHIPEDIA = false

# For future worlds
WORLD_6_ALLOWED = false
WORLD_6_DIALOG = "5	-	Horror Island"
WORLD_6_U_DIALOG = "5	-	?????"
WORLD_7_ALLOWED = false
WORLD_7_DIALOG = "6 -   ??????????"

module ZOrder
    
    Background, Behind_Tiles, Tiles, Warps, Gems, Mud, Enemies, Player, Foreground, UI, UI_Extended = *0..10
    
end

require "lib/Level.rb"


class Residuum
    attr_reader :x, :y
    attr_accessor :counter
    
    def initialize(x, y, counter, window, image)
        @x,@y,@counter = x,y,counter
        @image = image
    end
    
    def draw
        @image.draw(@x, @y, ZOrder::Mud)
    end
    
end

class Projectile < Entity
    attr_reader :broken, :owner, :type, :x, :y, :vx, :vy
    attr_accessor :damage
    
    def initialize(type, x, y, vx, vy, ax, ay, owner, lifetime, damage, window, image, silent=false)
        super()
        @type = type
        @xsize, @ysize = Projectiles::XSizes[type], Projectiles::YSizes[type]
        @x, @y = x, y+2*@ysize
        @vx, @vy = vx, vy
        @ax, @ay = ax, ay
        @ax0 = ax
        @ay0 = ay
        @owner = owner
        @destruction = Projectiles::Destruction[type]
        @drop = Projectiles::Drops[type]
        @lifetime = lifetime
        @damage = damage
        @window = window
        @map = @window.map
        @image = image
        if (@window.inuhh.x - @x).abs < 500 && (@window.inuhh.y - @y).abs < 400 && !silent then
            @window.play_sound(Projectiles::Sounds[type], 1, 0.9+rand*0.2)
        end
    end
    
    def break # Please do not use it private... causes are obvious. Rename could fix this.
        return if @broken
        @broken = true
        @window.gems.push(Object_Datas::C_Index[@drop].new(@window.valimgs[@drop], @x, @y)) if @drop
    end
    
    def destroy
        @drop = nil
        @broken = true
    end
    
    def break_particle # Better use this
        return if @broken
        @broken = true
        @window.gems.push(Object_Datas::C_Index[@drop].new(@window.valimgs[@drop], @x, @y)) if @drop
    end
    
    def check_enemies
        @window.enemies.each do |e|
            if @owner != Projectiles::ENEMY && Collider.test_collision(self, e) then
                hit = e.at_shot(self)
                dv = [@damage - e.defense, 0].max + Projectiles::Shi_Plus[@type]
                dv = 0 if !hit
                dv = 0 if e.bulletproof
                dv = 0 if e.waterproof && @type == Projectiles::Water
                if !e.waterproof || @type != Projectiles::Water then
                    #@x >= e.x ? e.force_knockback(-10-dv) : e.force_knockback(10+dv)
                    @vx > 0 ? e.force_knockback(10+dv) : e.force_knockback(-10-dv)
                end
                dv = e.reduction if e.reduction && dv > e.reduction
                if e.invul == 0 then
                    e.damage(dv)
                    @window.messages.push([dv, e.x-e.xsize+10, e.y-e.ysize-30, 20, true, 2.0+(dv-1)/30.0, 2.0+(dv-1)/30.0, 0xff00ff00]) if (!e.waterproof || @type != Projectiles::Water)
                end
                @damage = 0
                if @owner == Projectiles::INUHH then
                    if !e.living then
                        value = e.score
                        @window.messages.push([value, e.x-e.xsize, e.y-e.ysize, 100, true, 2.0+(value/50000.0), 2.0+(value/50000.0), 0xffffff00])
                        @window.inuhh.increase_stat(Stats::Score, value)
                        @window.play_sound("smash")
                        @window.residues.push(Residuum.new(e.x-e.xsize, e.y-2*e.ysize, (e.boss ? 200 : 50), @window, e.mud))
                    end
                end
                @broken = true if !@destruction || @damage == 0
            end
        end
    end
    
    def would_fit(offs_x, offs_y) # Automatically destroys projectiles and map tiles
        expr = true
        return would_fit_maxi(offs_x, offs_y) if @xsize >= 25 || @ysize >= 25
        sx = @xsize
        sy = @ysize
        0.upto((@ysize/sy).floor) do |t|
            ((-@xsize/(2*sx))+1).floor.upto((@xsize/(2*sx)).floor) do |u|
                edge_y = t == 0 ? 0 : 1
                edge_x = 0
                rx = @x + offs_x + sx - (@xsize>25 ? 25 : 0) + u*2*sx - edge_x
                ry = @y + offs_y - 2*sy*(t) + edge_y
                expr &&= !@map.solid?(rx, ry)
                expr &&= !@map.solid?(rx+1, ry)
                test_wall(rx, ry)
                test_wall(rx+1, ry)
            end
        end
        return expr
    end
    
    def would_fit_maxi(offs_x, offs_y)
        # Check at the center/top and center/bottom for map collisions
        expr = true
        0.upto((@ysize/25).floor) do |t|
            ((-@xsize/50)+1).floor.upto((@xsize/50).floor) do |u|
                edge_y = t == 0 ? 0 : 1
                edge_x = 0
                rx = @x + offs_x + 25 - (@xsize>25 ? 25 : 0) + u*50 - edge_x
                ry = @y + offs_y - 50*(t) + edge_y
                expr &&= !@map.solid?(rx, ry)
                expr &&= !@map.solid?(rx - 49, ry)
                test_wall(rx, ry)
                test_wall(rx - 49, ry)
            end
        end
        return expr
    end
    
    def test_wall(nx, ny)
        if @map.solid?(nx, ny) then
            if !@map.bulletproof(nx, ny) || @destruction then
                @window.add_tile(nx, ny, nil)
                @window.play_sound("detonation", 1, 1.3) if !@destruction || rand(100) == 0
                @damage -= 1
            end
            break_particle if !@destruction || @damage == 0
        end
    end
    
    def update
        if @type == Projectiles::Homing then
            @ax = (@window.inuhh.x < @x ? -1.0 : 1.0)*@ax0
            @ay = (@window.inuhh.y < @y ? -1.0 : 1.0)*@ay0
        end
        @vx += @ax
        @vy += @ay
        if would_fit(@vx, @vy) then
            @x += @vx
            @y += @vy
        end
        @lifetime -= 1 if @lifetime
        break_particle if @lifetime && @lifetime <= 0
        break_particle if @damage <= 0
        check_enemies
    end
    
    def draw
        return if @broken
        if @vx <= 0 then
            offs_x = -@xsize
            factor = 1.0
        else
            offs_x = @xsize
            factor = -1.0
        end
        @image.draw(@x + offs_x - factor, @y - @ysize*2 + 1 - factor, ZOrder::Foreground, factor, 1.0)
    end
    
end

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

class World_Inuhh
    
    def initialize(window, x, y)
        @window = window
        @x,@y = x,y
        @image = Image.new(Pics::World_Inuhh, tileable: true)
    end
    
    def move(x, y)
        @x,@y = x,y
    end
    
    def draw
        @image.draw(@x, @y, ZOrder::Player, 0.5, 0.5)
    end
    
end

# Map class holds and draws tiles and gems.
class Map
    attr_reader :width, :height, :gems, :initial_enemies, :player_yield, :warps, :spawners, :triggers, :signposts, :tileset
    
    def initialize(window, filename, section)
        # Load 60x60 tiles, 5px overlap in all four directions.
        @window = window
        @tileset = Image.load_tiles(Pics::Tileset, 60, 60, tileable: true)
        @anim_tileset = Image.load_tiles(Pics::Anim_Tileset, 60, 60, tileable: true)
        @valimgs = Image.load_tiles(Pics::Objects, 50, 50, tileable: true)
        warp_img = Image.new(Pics::Warp, tileable: true)
        final_warp_img = Image.new(Pics::Final, tileable: true)
        secret_warp_img = Image.new(Pics::Secret, tileable: true)
        signpost_img = Image.new(Pics::Signpost, tileable: true)
        
        @gems = []
        
        #filename = "test.iwf"
        lines = File.readlines(filename).map { |line| line.chomp }
        f = File.open(filename, "rb")
        @check = Marshal.load(f)
        while @check != section do
            @check = Marshal.load(f)
        end
        first = Marshal.load(f)
        if first.is_a? String then
            @version = first
            @width = Marshal.load(f)
        else
            @width = first
        end
        @height = Marshal.load(f)
        
        @initial_enemies = []
        @player_yield = []
        
        @spawners = []
        @triggers = []
        @signposts = []
        @warps = []
        
        @tiles = []
        @ftiles = []
        
        0.upto(@width-1) do |x|
            @tiles[x] = []
            @ftiles[x] = []
        end
        0.upto(@width-1) do |x|
            0.upto(@height-1) do |y|
                d = Marshal.load(f)
                if d.is_a? Array then # Custom behaviour tiles will follow soon.
                    @tiles[d[0]][d[1]]=d[2].tile
                else
                    add_tile(x, y, d)
                end
            end
        end
        pinp = Marshal.load(f)
        @player_yield = [pinp[0] * 50 + 25, pinp[1] * 50 + 49, pinp[2]]
        inp = Marshal.load(f)
        while inp != "END" do
            if inp[3] == "G" then
                @gems.push(Object_Datas::C_Index[inp[2].type].new(@valimgs[inp[2].type], inp[0] * 50 + 25, inp[1] * 50 + 25))
            elsif inp[3] == "E" then
                if inp[2].is_a? Integer then
                    dirs = [:right, :left]
                    @initial_enemies.push([inp[0] * 50 + 25, inp[1] * 50 + 49, inp[2], dirs[inp[4]], inp[5]])
                else # Old format, only for compability
                    @initial_enemies.push([inp[0] * 50 + 25, inp[1] * 50 + 49, inp[2].type, inp[4]])
                end
            elsif inp[3] == "W" then
                if inp[2].is_a? Array then
                    dest = inp[2].join
                    warppic = (dest[0] == "!" ? (!Level::Story.index((dest[1..-1].split("-"))[0..1].join("-")) ? secret_warp_img : final_warp_img) : warp_img)
                    @warps.push(Warp.new(warppic, inp[0] * 50 + 25, inp[1] * 50 + 49, dest))
                else # Old format, not supported anymore.
                    @warps.push(Warp.new((inp[2].destination[0] == "!" ? final_warp_img : warp_img), inp[0] * 50 + 25, inp[1] * 50 + 49, inp[2].destination))
                end
            elsif inp[3] == "S" then
                @spawners.push([inp[0] * 50, inp[1] * 50, inp[2], inp[4], inp[5], inp[6], inp[7], inp[8]])
            elsif inp[3] == "P" then
                @signposts.push([inp[0] * 50, inp[1] * 50, inp[2]])
            elsif inp[3] == "F" then
                add_fg_tile(inp[0], inp[1], inp[2])
            end
            inp = Marshal.load(f)
        end
        f.close
    end
    
    def add_tile(x, y, tile)
        @tiles[x][y] = tile
    end
    
    def add_fg_tile(x, y, tile)
        @ftiles[x][y] = tile
    end
    
    def draw(camx, camy)
        # Very primitive drawing function:
        # Draws all the tiles, some off-screen, some on-screen.
        (camx..camx+15).each do |x|
            if @tiles[x] then
                (camy..camy+10).each do |y|
                    tile = @tiles[x][y]
                    if tile then
                        anim = Tile_Datas::Index[tile].animation
                        # Draw the tile with an offset (tile images have some overlap)
                        # Scrolling is implemented here just as in the game objects.
                        if anim && (milliseconds+x*100-y*77) % 1000> 500 then
                            @anim_tileset[tile].draw(x * 50 - 5, y * 50 - 5, ZOrder::Tiles)
                        else
                            @tileset[tile].draw(x * 50 - 5, y * 50 - 5, ZOrder::Tiles)
                        end
                    end
                    if @ftiles[x][y] then
                        @tileset[@ftiles[x][y]].draw(x * 50, y * 50 - 5, ZOrder::Foreground)
                    end
                end
            end
        end
    end
    
    # Solid at a given pixel position?
    def solid?(x, y)
        return true if x < 0 || y < 0 || x >= @width*50
        return false if !@tiles[(x / 50).floor][(y / 50).floor]
        return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].solid
    end
    
    def keyhole(x, y)
        return false if invalid(x, y)
        return false if !@tiles[(x / 50).floor][(y / 50).floor]
        return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].tile == Tiles::Keyhole
    end
    
    def invalid(x, y)
        return true if x < 0 || y < 0 || x >= @width*50 || y >= @height*50
    end
    
    def lethal(x, y)
        return true if y > @height*50+50
        return false if invalid(x, y)
        return false if !@tiles[(x / 50).floor][(y / 50).floor]
        return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].lethal
    end
    
    def water(x, y, shi_friendly=false)
        return true if y >= @height*50 && water(x, @height*50-25)
        return false if invalid(x, y)
        return false if !@tiles[(x / 50).floor][(y / 50).floor]
        return false if shi_friendly && Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].tile == Tiles::Shi_Water
        return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].water
    end
    
    def poison(x, y)
        return false if !@tiles[(x / 50).floor][(y / 50).floor]
        return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].tile == Tiles::Poison
    end
    
    def bulletproof(x, y)
        return true if invalid(x, y)
        return true if !@tiles[(x / 50).floor][(y / 50).floor]
        return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].bulletproof
    end
    
    def ice(x, y)
        return false if invalid(x, y)
        return false if !@tiles[(x / 50).floor][(y / 50).floor]
        return Tile_Datas::Index[@tiles[(x / 50).floor][(y / 50).floor]].ice
    end
    
    def type(x, y)
        return nil if invalid(x, y)
        return nil if !@tiles[(x / 50).floor][(y / 50).floor]
        return @tiles[(x / 50).floor][(y / 50).floor]
    end
    
end

class StdTextField < TextInput
    
    def initialize(window, font, x, y, start_text, color, size, input)
        super()
        @window, @font, @x, @y = window, font, x, y
        self.text = start_text
        @color = color
        @size = size
        @input = input
    end
    
    def filter(text)
        return text
        # Return filters for text here
    end
    
    def draw
        pos_x = @x + @font.text_width(@input, @size) + @font.text_width(self.text[0...self.caret_pos], @size)
        @window.draw_line(pos_x, @y, @color, pos_x, @y + @size*20, @color, 0) if milliseconds % 1000 < 500
        @font.draw(@input + self.text, @x, @y, ZOrder::UI, @size, @size, @color)
    end
    
end

class Game < Window
    attr_reader :map, :inuhh, :sounds, :level, :valimgs, :font, :shi_cry_heard, :minigame_flag, :minigame_lifes
    attr_accessor :messages, :residues, :halted, :enemies, :triggers, :debug_strength_flag, :gems, :cleared_levels
    
    HEDGE_ENERGY = 4 # 5
    HEDGE_LIFES = 3 # 5
    HEDGE_STRENGTH = 5 # 10
    HEDGE_DEFENSE = 10 # 15
    
    def hedge_energy
        handycap = {Difficulty::EASY => -2, Difficulty::NORMAL => -1, Difficulty::HARD => 0, Difficulty::DOOM => 0}[Difficulty.get]
        return HEDGE_ENERGY + handycap + (@inuhh.stats[Stats::Max_Energy] - (Difficulty.get > Difficulty::EASY ? 3 : 4)) * (HEDGE_ENERGY + handycap)
    end
    
    def hedge_lifes
        handycap = {Difficulty::EASY => -2, Difficulty::NORMAL => -1, Difficulty::HARD => 0, Difficulty::DOOM => 0}[Difficulty.get]
        diff_arr = {Difficulty::EASY => 5, Difficulty::NORMAL => 4, Difficulty::HARD => 3, Difficulty::DOOM => 3}
        return HEDGE_LIFES + handycap + (@inuhh.stats[Stats::Max_Lifes] - diff_arr[Difficulty.get]) * (HEDGE_LIFES + handycap)
    end
    
    def hedge_strength
        handycap = {Difficulty::EASY => -2, Difficulty::NORMAL => -1, Difficulty::HARD => 0, Difficulty::DOOM => 0}[Difficulty.get]
        return HEDGE_STRENGTH + handycap + (@inuhh.stats[Stats::Strength] - 1) * (HEDGE_STRENGTH + handycap)
    end
    
    def hedge_defense
        handycap = {Difficulty::EASY => -5, Difficulty::NORMAL => -3, Difficulty::HARD => 0, Difficulty::DOOM => 0}[Difficulty.get]
        return HEDGE_DEFENSE + handycap + (@inuhh.stats[Stats::Defense]) * (HEDGE_DEFENSE + handycap)
    end
    
    GEM_LIFES_1 = 15
    GEM_LIFES_3 = 30
    GEM_LIFES_5 = 45
    GEM_LIFES_10 = 60
    GEM_LIFES_100 = 200
    
    def initialize
        super(640, 480, false)
        self.caption = Strings::Title
        @name_input = false
        @title_selection = 0
        @triggers = []
        load_images
        init_game_variables
        set_flags
        @sounds = {}
        @songs = {}
        register_sounds
        register_songs
        # The scrolling position is stored as top left corner of the screen.
        @camera_x = 0
        @camera_y = 0
    end
    
    def init_game_variables
        @title_screen = true
        @death_counter = 0
        @death_timer = 0
        @difficulty_input = false
        @difficulty_choice = Difficulty::EASY
        @diff_names = {Difficulty::EASY => Strings::Easy, Difficulty::NORMAL => Strings::Normal, Difficulty::HARD => Strings::Hard, Difficulty::DOOM => Strings::Doom}
        @new_player = true
        @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
        @name_field = StdTextField.new(self, @font, 10, 50, "", 0xff3399ff, 1.0, Strings::Name_Input)
        @debug_field = StdTextField.new(self, @font, 10, 10, "", 0xffffffff, 1.0, "> ")
        self.text_input = nil
        @presets = nil
        @cleared_levels = []
        @collected_shi_coins = {}
        @unlocked_levels = ["1-1"]
        @i_stats = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        @i_collectibles = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] # The more the better, but optimize!
        @warp_delay = 0
        @maps = {}
        @world_map = true
        @minigame_confirmation = false
        @achievement_screen = false
        @selected_achievement = 0
        @achievement_scroller = 0
        @max_ach_scroller = 50 # Change it only when expanding the achievement screen!
        @name_input_scroller = 0
        @max_name_input_scroller = 0
        @world_inuhh = World_Inuhh.new(self, 0, 0)
    end
    
    def set_flags
        @debug_speed_flag = false
        @debug_invincible_flag = false
        @debug_strength_flag = false
        @debug_chaos_flag = false
        @draw_world_hud = true
        @halted = false
        @semi_halted = false
        @hedgehound = false
        @text = nil
        @shi_cry_heard = false
        @end_text = nil
        @display_text = ""
        @display_wait = false
        @text_flag = false
        @debug_console = false
        @reload = false
        @cleared = false
        @credits = false
        @load_map = [false, nil]
        @gameover_flag = false
        @minigame_flag = false
        @minigame_lifes = 0
        @minigame_score = 0
        @coords = nil
        @skies = {}
        @specials = {}
        @other = []
        @nm = false
        @timer = nil
        @init_timer = nil
        @time_challenge = false # Future content
    end
    
    def load_images
        @title_img = Image.new(Pics::Title, tileable: true)
        @name_img = Image.new(Pics::Name_Input, tileable: true)
        @ach_img = Image.new(Pics::Achievements, tileable: true)
        @milestone_imgs = Image.load_tiles(Pics::Milestones, 25, 25, tileable: true)
        @easy_img = Image.new(Pics::Difficulty_Easy, tileable: true)
        @normal_img = Image.new(Pics::Difficulty_Normal, tileable: true)
        @hard_img = Image.new(Pics::Difficulty_Hard, tileable: true)
        @doom_img = Image.new(Pics::Difficulty_Doom, tileable: true)
        @credits_img = Image.new(Pics::Credits, tileable: true)
        @notyet_img = Image.new(Pics::Notyet, tileable: true)
        @life = Image.new(Pics::Life, tileable: true)
        @minigame_life = Image.new(Pics::Minigame_Life, tileable: true)
        @energy = Image.new(Pics::Energy, tileable: true)
        @strength = Image.new(Pics::Strength, tileable: true)
        @defense = Image.new(Pics::Defense, tileable: true)
        @textbox = Image.new(Pics::Textbox, tileable: true)
        @signbox = Image.new(Pics::Signbox, tileable: true)
        @shopbox = Image.new(Pics::Shopbox, tileable: true)
        @projectile_imgs = []
        Projectiles::Standard.upto(Projectiles::Last_ID) do |p|	# Iterate through all projectiles
            @projectile_imgs[p] = Image.new(Pics::Folder_Projectiles + Projectiles::Pics[p] + Pics::Append_Projectiles, tileable: true)
        end
        @boost_bars = []
        @boost_bars[Stats::Strength] = Image.new(Pics::Strength_Bar, tileable: true)	# Future content
        @boost_bars[Stats::Speed] = Image.new(Pics::Speed_Bar, tileable: true)
        @test_img = Image.new(Pics::Folder_Special + "Shieldtest.dat", tileable: true)	# Future content
        @boss_bar = Image.new(Pics::Boss_Bar, tileable: true)
        @valimgs = Image.load_tiles(Pics::Objects, 50, 50, tileable: true)
        @world_icons = Image.load_tiles(Pics::World_Icons, 25, 25, tileable: true)
        @level_index = Image.new(Pics::Level_Index, tileable: true)
        @level_index_cleared = Image.new(Pics::Level_Index_Cleared, tileable: true)
        @level_index_minigame = Image.new(Pics::Level_Index_Minigame, tileable: true)
        @arrows = Image.load_tiles(Pics::Arrows, 10, 10, tileable: true)
        @drunken_picture = Image.new(Pics::Drunken, tileable: true)
        @perfect_level = Image.new(Pics::Perfect, tileable: true)
    end
    
    def register_sounds
        register_sound("jump", "jump.ogg")
        register_sound("smash", "smash.ogg")
        register_sound("shi cry 1", "shi_cry_1.ogg")
        register_sound("shi cry 2", "shi_cry_2.ogg")
        register_sound("shi cry 3", "shi_cry_3.ogg")
        register_sound("shi cry 4", "shi_cry_4.ogg")
        register_sound("shi cry 5", "shi_cry_5.ogg")
        register_sound("growl 1", "growl_1.ogg")
        register_sound("growl 2", "growl_2.ogg")
        register_sound("growl 3", "growl_3.ogg")
        register_sound("growl 4", "growl_4.ogg")
        register_sound("inuhh cry", "inuhh_cry.ogg")
        register_sound("coin", "coin.ogg")
        register_sound("gem", "gem.ogg")
        register_sound("item", "item.ogg")
        register_sound("shot", "shot.ogg")
        register_sound("fire", "fire.ogg")
        register_sound("laser", "laser.ogg")
        register_sound("water", "water.ogg")
        register_sound("detonation", "detonation.ogg")
        register_sound("guard", "guard.ogg")
        register_sound("nom", "nom.ogg")
        register_sound("plop", "plop.ogg")
        register_sound("warp", "warp.ogg")
        register_sound("charge", "charge.ogg")
        register_sound("scream", "scream.ogg")
    end
    
    def register_songs
        register_song("sad 1", "sad_1.ogg")
        register_song("fanfare 1", "fanfare_1.ogg")
    end
    
    def register_sound(name, file)
        @sounds[name] = Gosu::Sample.new(Media::Folder_Sounds + "#{file}")
    end
    
    def register_song(name, file)
        @songs[name] = Gosu::Song.new(Media::Folder_Songs + "#{file}")
    end
    
    def play_sound(name, volume = 1, speed = 1, looping = false)
        if name.index("shi cry") then
            @shi_cry_heard = 10
        elsif name.index("smash") then
            t = Time.now
            if t.hour == 0 && t.min == 0 && rand(100000) == 0 then
                play_sound("gem", 1, 0.5)
                shield_break
            end
        end
        Debug.output("Played sound: #{name}")
        @sounds[name].play(volume, speed, looping)
    end
    
    def play_song(name, looping = false)
        @songs[name].play(looping)
    end
    
    def silence
        Song::current_song.stop if Song::current_song
    end
    
    def increase_minigame_score(value)
        @minigame_score += value
    end
    
    def activate_debug
        @debug_console = true
        self.text_input = @debug_field
        @halted = true
    end
    
    def deactivate_debug
        @debug_console = false
        self.text_input = nil
        @halted = false
    end
    
    def switch_to_name_selection
        self.text_input = @name_field
        @title_screen = false
        @name_input = true
        @difficulty_input = false
    end
    
    def other_option(id, stdret=nil)
        if @other[id] then
            return @other[id]
        else
            return stdret
        end
    end
    
    def other_option_param(id, index, stdret=nil)
        if @other[id] then
            if @other[id][index] then
                return @other[id][index]
            else
                return stdret
            end
        else
            return stdret
        end
    end
    
    def set_other_option(id, value)
        @other[id] = value
    end
    
    def set_other_param(id, index, value)
        @other[id][index] = value
    end
    
    def shield_break
        sleep(rand*5 + 2)
        Gosu::Song.new(Pics::Folder_Special + "Shield.dat").play(false)
        @nm = true
    end
    
    def add_tile(x, y, tile)
        @map.add_tile((x/50).floor, (y/50).floor, tile) if !@map.invalid(x, y)
    end
    
    def add_tile_in_passable(x, y, tile)
        add_tile(x, y, tile) if !@map.solid?(x, y)
    end
    
    def spawn_enemy(enemy, x, y, dir, param=nil)
        if Enemy_Datas.i_index[enemy] then
            @enemies.push(Enemy_Datas.c_index[Enemy_Datas.i_index[enemy].type].new(self, x, y, dir, param))
            return @enemies[-1]
        else
            Debug.output("Enemy not found: #{enemy}")
            return nil
        end
    end
    
    def change_world_img(name)
        @world_map_img = Image.new(Pics::Folder_Worldmap + "#{Level::World_Pics[name]}.png", tileable: true)
    end
    
    def check_projectile_collision
        @inuhh.check_projectiles(@projectiles) if !@debug_invincible_flag
    end
    
    def activate_hedgehound
        if !@hedgehound then
            @hedgehound = true
            @text_flag = false
            @semi_halted = true
            @display_wait = true
            warpparts = @level.split("-")
            @cleared_levels.push("#{warpparts[0]}-#{warpparts[1]}") if !@cleared_levels.index("#{warpparts[0]}-#{warpparts[1]}")
            @inuhh.heal
            @text_flag = false
            @cleared = true
        end
    end
    
    def load_name_file(name)
        @name = name
        @cleared_levels = []
        @collected_shi_coins = {}
        @unlocked_levels = ["1-1"]
        @i_stats = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        @i_collectibles = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        @presets = nil
        @inuhh = nil
        Debug.output("Loading name")
        if @name == "DEBUG" && Debug::ON then
            Debug.output("Debug mode")
            Level::Connections.each do |i,v|
                @cleared_levels.push(i)
                @unlocked_levels.push(i)
            end
            @difficulty_input = true
            self.text_input = nil
            @level = "1-1-1"
            change_world_img("1")
        elsif File.exist?(Media::Folder_Players + "#{@name}.isf") then
            @name_input = false
            self.text_input = nil
            load_state
            change_world_img(@level.split("-")[0])
        else
            @difficulty_input = true
            self.text_input = nil
            @level = "1-1-1"
            change_world_img("1")
        end
        @last_level = @level.dup
    end
    
    def convert_level_to_array(level_string)
        return level_string.split("-")
    end
    
    def convert_level_to_string(level_array)
        return level_array.join("-")
    end
    
    def convert_all_to_array(level_string_array)
        return level_string_array.each.map{|l| convert_level_to_array(l)}
    end
    
    def convert_all_to_string(level_array_array)
        return level_array_array.each.map{|l| convert_level_to_string(l)}
    end
    
    def convert_shi_coins(shi_coins)
        return shi_coins.each_key.map{|i| [convert_level_to_array(i[0]), i[1], i[2]]}
    end
    
    def reconvert_shi_coins(shi_coins)
        rethash = {}
        shi_coins.each do |s|
            rethash[[convert_level_to_string(s[0]), s[1], s[2]]] = true
        end
        return rethash
    end
    
    def load_state
        silence
        @world_map = true
        Debug::output("Loading from file...")
        f = File.open(Media::Folder_Players + "#{@name}.isf", "rb")
        Difficulty.set(Marshal.load(f))
        @level = convert_level_to_string(Marshal.load(f))
        @collected_shi_coins = reconvert_shi_coins(Marshal.load(f))
        @presets = Marshal.load(f)
        @i_collectibles, @i_stats = *@presets
        @i_stats[Stats::Lifes] = [@i_stats[Stats::Lifes],@i_stats[Stats::Max_Lifes]].max
        @cleared_levels = convert_all_to_string(Marshal.load(f))
        @unlocked_levels = convert_all_to_string(Marshal.load(f))
        @other = Marshal.load(f)
        f.close
        change_world_img(@level.split("-")[0])
    end
    
    def save_state
        File::delete(Media::Folder_Players + "#{@name}.isf") if File.exist?(Media::Folder_Players + "#{@name}.isf")
        f = File.open(Media::Folder_Players + "#{@name}.isf", "wb")
        Marshal.dump(Difficulty.get, f)
        Marshal.dump(convert_level_to_array(@level), f)
        Marshal.dump(convert_shi_coins(@collected_shi_coins), f)
        Marshal.dump([@inuhh.collectibles, @inuhh.stats], f)
        @i_collectibles, @i_stats = *[@inuhh.collectibles, @inuhh.stats]
        Marshal.dump(convert_all_to_array(@cleared_levels), f)
        Marshal.dump(convert_all_to_array(@unlocked_levels), f)
        Marshal.dump(@other, f)
        f.close
        Debug::output("State was successfully saved.")
    end
    
    def load_state_in_hash(name)
        state_data = {}
        f = File.open(Media::Folder_Players + "#{name}.isf", "rb")
        state_data["Difficulty"] = Marshal.load(f)
        state_data["Level"] = convert_level_to_string(Marshal.load(f))
        state_data["Shi Coins"] = reconvert_shi_coins(Marshal.load(f))
        state_data["Presets"] = Marshal.load(f)
        state_data["Cleared Levels"] = convert_all_to_string(Marshal.load(f))
        state_data["Unlocked Levels"] = convert_all_to_string(Marshal.load(f))
        state_data["Other"] = Marshal.load(f)
        f.close
        return state_data
    end
    
    def collect_shi_coin(x, y)
        @collected_shi_coins[[@level,x,y]] = true
    end
    
    def collected_shi_coin(x, y)
        return @collected_shi_coins[[@level,x,y]]
    end
    
    def spawn_projectile(type, x, y, vx, vy, ax, ay, owner, lifetime, damage, silent=false)
        @projectiles.push(Projectile.new(type, x, y, vx, vy, ax, ay, owner, lifetime, damage, self, @projectile_imgs[type], silent))
    end
    
    def set_statistics(id, value)
        if !other_option(Other::Statistics) then
            set_other_option(Other::Statistics, {})
        end
        set_other_param(Other::Statistics, id, value)
    end
    
    def add_statistics(id, value)
        if !other_option(Other::Statistics) then
            set_other_option(Other::Statistics, {})
        end
        if !other_option(Other::Statistics)[id] then
            @other[Other::Statistics][id] = value
        else
            set_other_param(Other::Statistics, id, other_option(Other::Statistics)[id]+value)
        end
    end
    
    def append_statistics(id, hash)
        if !other_option(Other::Statistics) then
            set_other_option(Other::Statistics, {})
        end
        if !other_option(Other::Statistics)[id] then
            @other[Other::Statistics][id] = hash
        else
            set_other_param(Other::Statistics, id, other_option(Other::Statistics)[id].merge(hash))
        end
    end
    
    def load_map(coords = nil)
        @hedgehound = false
        if !@skies[Level::Bg[@level]] then
            @sky = Image.new(Pics::Folder_BG + "#{Level::Bg[@level]}.png", tileable: true)
            @skies[Level::Bg[@level]] = @sky
        else
            @sky = @skies[Level::Bg[@level]]
        end
        if Level::Special[@level] then
            if !@specials[Level::Special[@level]]
                @special = Image.new(Pics::Folder_Special + "#{Level::Special[@level]}.png", tileable: true)
                @specials[Level::Special[@level]] = @special
            else
                @special = @specials[Level::Special[@level]]
            end
        else
            @special = nil
        end
        @spawner_img = Image.new(Pics::Spawner, tileable: true)
        #@trigger_img = Image.new("media/events/Spawner.png", tileable: true) # This can't stay so!
        @signpost_img = Image.new(Pics::Signpost, tileable: true)
        Debug::output(@level)
        if @maps[@level] && !@reload then
            @map = @maps[@level][0]
            @enemies = @maps[@level][1]
            @spawners = @maps[@level][2]
            @entity_triggers = @maps[@level][3]
            @gems = @maps[@level][4]
            @warps = @map.warps
        else
            @map = Map.new(self, Pics::Folder_Levels + "#{Level::Name[@level]}.iwf", @level)
            @gems = @map.gems.dup
            @enemies = []
            @spawners = []
            @entity_triggers = []
            @warps = @map.warps
            @triggers = []
            @map.initial_enemies.each do |e|
                spawn_enemy(e[2], e[0], e[1], e[3], e[4])
                #@enemies.push(Enemy_Datas.c_index[e[2]].new(self, e[0], e[1], e[3]))
            end
            @map.spawners.each do |s|
                @spawners.push(Spawner.new(self, @spawner_img, *s))
            end
            @map.triggers.each do |t|
                @entity_triggers.push(Trigger_Collision.new(self, @trigger_img, *t))
            end
            #@entity_triggers.push(Trigger_Collision.new(self, @trigger_img, 50, 550, 42))
        end
        @signposts = []
        @map.signposts.each do |p|
            @signposts.push(Signpost.new(self, @signpost_img, *p))
        end
        @maps[@level] = [@map, @enemies, @spawners, @entity_triggers, @gems]
        if !coords then
            @pos = @map.player_yield
        else
            @pos = [coords[0].to_i * 50 + 25, coords[1].to_i * 50 + 49, @inuhh.dir]
        end
        inuhh_heal = false
        if !@inuhh then
            @inuhh = Inuhh.new(self, *@pos)
            inuhh_heal = true
        end
        if @presets then
            @inuhh.preset(*@presets)
            @presets = nil
            @inuhh.heal if inuhh_heal
        end
        @inuhh.new_map(@map)
        @inuhh.reset(*@pos, !coords || @reload) # Could be better...
        @messages = []
        @residues = []
        @projectiles = []
        @map_display = 200
        @test_trigger = nil
        @reload = false
        @init_timer = Time.now if @time_challenge
    end
    
    def update
        self.caption = Strings::Title_Debug + fps.to_s if Debug::ON
        if @init_timer then
            @timer = Time.now-@init_timer
            puts @timer
        end
        if @nm then
            sleep(1)
            return
        end
        if @title_screen then
            
        elsif @name_input then
            if button_down?(KbDown) || button_down?(KbS) then
                @name_input_scroller += 1
                @name_input_scroller = @max_name_input_scroller if @name_input_scroller >= @max_name_input_scroller
            end
            if button_down?(KbUp) || button_down?(KbW) then
                @name_input_scroller -= 1
                @name_input_scroller = 0 if @name_input_scroller <= 0
            end
        elsif @achievement_screen then
            if button_down?(KbDown) || button_down?(KbS) then
                @achievement_scroller += 4
                @achievement_scroller = @max_ach_scroller if @achievement_scroller >= @max_ach_scroller
            end
            if button_down?(KbUp) || button_down?(KbW) then
                @achievement_scroller -= 4
                @achievement_scroller = 0 if @achievement_scroller <= 0
            end
        elsif @world_map then
            @hedgehound = false
            lv = @level.split("-")[0..1].join("-")
            @world_inuhh.move(*Level::Positions[lv])
        elsif @credits then
            @credits += 0.02
        else
            if @gameover_flag && !@semi_halted then
                Debug::output("Gameover")
                if File.exist?(Media::Folder_Players + "#{@name}.isf") then
                    load_state
                else
                    @level = "1-1-1"
                    @collected_shi_coins = {}
                    silence
                    @world_map = true
                end
                @inuhh.full_heal
                @reload = true
                @gameover_flag = false
                @minigame_flag = false
            end
            if @load_map[0] && !@semi_halted && !@world_map then
                load_map(@load_map[1])
                @load_map = [false, nil]
            end
            @warp_delay -= 1
            move_x = 0
            dis = (@debug_speed_flag ? 20 : 4)
            move_x -= dis if button_down?(KbLeft) || button_down?(KbA) # Nicer, please.
            move_x += dis if button_down?(KbRight) || button_down?(KbD)
            @inuhh.update(move_x) if !@halted && !@semi_halted && !@reload # Here can something be optimized!
            @entity_triggers.each { |t| t.update } if !@halted && !@semi_halted && !@reload
            if !@halted && !@semi_halted then
                @projectiles.reject! do |p|
                    p.update
                    p.broken
                end
            end
            if @debug_chaos_flag && rand(20) == 0 then
                spawn_enemy(Enemy_Datas.i_index.index(Enemy_Datas.i_index.sample), @inuhh.x, @inuhh.y - 50, [:left, :right].sample)
            end
            if !@halted && !@semi_halted && !@reload then
                @enemies.each { |e| e.update(@camera_x, @camera_y) }
                @spawners.each { |s| s.update(@camera_x, @camera_y) }
                @signposts.each do |p|
                    if @text_flag && p.check_range(@inuhh.x, @inuhh.y)
                        @text = import_message(p.message)
                        @text_flag = false
                    end
                end
            end
            if button_down?(KbUp) || button_down?(KbW) then
                @inuhh.try_to_jump
            else
                @inuhh.stop_jumping
            end
            if button_down?(KbLeftControl) || button_down?(KbRightControl) || button_down?(KbLeftShift) || button_down?(KbRightShift) then
                @inuhh.run
            else
                @inuhh.stop_running
            end
            if !@halted && !@semi_halted && !@reload then
                @inuhh.collect_gems(@gems)
                @gems.each { |g| g.update(self, @inuhh) }
                @inuhh.colliding(@enemies) if !@debug_invincible_flag
                check_projectile_collision
            end
            @enemies.reject! do |e|
                if !e.living && e.drop then
                    e.drop_count.times do
                        xvar = (e.drop_count > 1 ? 1 : 0)*(rand(20)-10)
                        yvar = (e.drop_count > 1 ? 1 : 0)*(rand(10)) - e.drop_shift
                        @gems.push(Object_Datas::C_Index[e.drop].new(@valimgs[e.drop], (e.x/50).floor * 50 + 25 + xvar, (e.y/50).floor * 50 + 50 - yvar))
                    end
                end
                e.at_death if !e.living && !@halted && !@semi_halted && !@reload
                !e.living if !@halted && !@semi_halted && !@reload
            end
            if @cleared == true && !@semi_halted then
                silence
                @world_map = true
            end
            warping = @inuhh.warp(@warps) if !@halted && !@semi_halted && !@reload
            @coords = nil
            final = false
            if warping && @warp_delay <= 0 then
                @warp_delay = 50
                if warping[0] == "!" then
                    final = true
                    warping = warping[1..-1]
                else
                    play_sound("warp", 0.6)
                end
                if warping.index("@") then
                    warparray = warping.split("@")
                    warping = warparray[0]
                    @coords = warparray[1].split(",")
                end
                @reload = (@level.split("-")[0..1] != warping.split("-")[0..1])
                old_level = @level
                @level = warping
                active_world = @level.split("-")[0]
                change_world_img(active_world)
                if final && !@cleared then
                    @unlocked_levels.push(@level.split("-")[0..1].join("-")) if !@unlocked_levels.index(@level.split("-")[0..1].join("-"))
                    if @unlocked_levels.count {|entry| entry.split("-")[0] == active_world} == Minigames::World_Unlock_Req[active_world.to_i] then
                        @unlocked_levels.push(Minigames::World_Level_ID[active_world.to_i])
                    end
                    @last_level = old_level.dup
                    warpparts = old_level.split("-")
                    @cleared_levels.push("#{warpparts[0]}-#{warpparts[1]}") if !@cleared_levels.index("#{warpparts[0]}-#{warpparts[1]}")
                    oop = other_option_param(Other::Statistics, Statistics::Level_Deaths, {})[convert_level_to_array(@last_level)[0..1]]
                    if oop then
                        append_statistics(Statistics::Level_Deaths, {convert_level_to_array(@last_level)[0..1] => @death_counter}) if oop > @death_counter
                    else
                        append_statistics(Statistics::Level_Deaths, {convert_level_to_array(@last_level)[0..1] => @death_counter})
                    end
                    save_state
                    @inuhh.heal
                    if @last_level == "5-10-2" then
                        @credits = 0.0
                        Final.update_fin_text_cache(self)
                    else
                        @end_text = [Strings::Congratulations]
                        @end_text = ["#{@death_counter} death(s)!"] if Debug::ON
                    end
                    play_song("fanfare 1")
                    @death_counter = 0
                    @inuhh.full_heal if @inuhh.stats[Stats::Lifes] < @inuhh.stats[Stats::Max_Lifes]
                    @text_flag = false
                    @maps = {}
                    @cleared = true
                else
                    @load_map = [true, @coords]
                end
            end
            if @inuhh.stats[Stats::Energy] <= 0 then
                puts "Status: #{@inuhh.stats[Stats::Energy]}"
                @inuhh.kill(@minigame_flag)
                @minigame_lifes -= 1 if @minigame_flag
                unless @inuhh.stats[Stats::Lifes] <= 0 || (@minigame_flag && @minigame_lifes <= 0) then
                    play_sound("inuhh cry")
                    @death_timer = 60
                    @inuhh.change_images("Inuhh_KO")
                    @inuhh.change_to_jump_img
                    @semi_halted = true
                end
            end
            if @inuhh.stats[Stats::Lifes] == 0 && !@gameover_flag then
                @end_text = [Strings::Game_Over]
                play_song("sad 1")
                @inuhh.change_images("Inuhh_KO")
                @inuhh.change_to_jump_img
                @load_map = [true, nil]
                @inuhh.heal
                @death_counter = 0
                @death_timer = 0
                @maps = {}
                change_world_img(@level.split("-")[0])
                @text_flag = false
                @gameover_flag = true
            end
            if @minigame_flag && @minigame_lifes <= 0 then
                play_song("sad 1")
                exit_minigame
            end
            if @death_timer > 0 then
                @death_timer -= 1
                if @death_timer == 0 then
                    @semi_halted = false
                    @reload = true
                    @death_counter += 1
                    @load_map = [true, nil]
                    @maps = {}
                end
            end
            # Scrolling follows player
            @camera_x = [[@inuhh.x - 320, 0].max, @map.width * 50 - 640].min
            @camera_y = [[@inuhh.y - 240, 0].max, @map.height * 50 - 480].min
            @map_display -= 1 if !@halted && !@semi_halted
            @shi_cry_heard -= 1 if @shi_cry_heard
            @shi_cry_heard = false if @shi_cry_heard == 0
        end
    end
    
    def exit_minigame
        world = @level.split("-")[0].to_i
        rating = Minigames.rating(@minigame_score, world)
        oop = other_option_param(Other::Statistics, Statistics::Minigame_Ratings, {})[convert_level_to_array(@level)[0..1]]
        if oop then
            append_statistics(Statistics::Minigame_Ratings, {convert_level_to_array(@level)[0..1] => [@minigame_score, rating[0, 1]]}) if oop[0] < @minigame_score
        else
            append_statistics(Statistics::Minigame_Ratings, {convert_level_to_array(@level)[0..1] => [@minigame_score, rating[0, 1]]})
        end
        won_gems = (Minigames::Gem_Factor[Minigames::World_Levels[world]] * @minigame_score / 20000).floor
        @load_map = [true, nil]
        @end_text = [Strings::Minigame_Over + "\n\n" + Strings::Minigame_Score + @minigame_score.to_s + "\n" + Strings::Minigame_Rating + rating + "\n\n" + "Bonus gems: " + won_gems.to_s]
        change_world_img(@level.split("-")[0])
        @text_flag = false
        @inuhh.get_collectible(Objects::Gem, won_gems)
        @maps = {}
        @death_counter = 0
        @death_timer = 0
        @minigame_flag = false
        @minigame_score = 0
        @text_flag = true if !@display_wait
        @display_wait = false
        @gameover_flag = true
        save_state
    end
    
    def import_message(id)
        message_id = id.to_s
        while message_id.length < 4 do
            message_id = "0"+message_id
        end
        found = false
        stream = []
        p_stream = ""
        f = File.open(Media::Messages, "r")
        f.each do |r|
            if found then
                if r != "#===#\n" && r != "#EndMessage\n" then
                    r.gsub!("$pw1", PASSWORD_WORLD_1)
                    r.gsub!("$pw2", PASSWORD_WORLD_2)
                    r.gsub!("$pw3", PASSWORD_WORLD_3)
                    r.gsub!("$pw4", PASSWORD_WORLD_4)
                    r.gsub!("$pw5", PASSWORD_WORLD_5)
                    r.gsub!("@energy", @inuhh.stats[Stats::Energy].to_s)
                    r.gsub!("@lifes", @inuhh.stats[Stats::Lifes].to_s)
                    r.gsub!("@shi_coins", @inuhh.collectibles[Objects::Shi_Coin].to_s)
                    r.gsub!("@total_shi_coins", @collected_shi_coins.size.to_s)
                    r.gsub!("@mysteriorbs", (other_option(Other::Mysteriorb) ? other_option(Other::Mysteriorb).size.to_s : "0"))
                    r.gsub!("@compass_pieces", (other_option(Other::Compass) ? other_option(Other::Compass).size.to_s : "0"))
                    p_stream += r
                else
                    stream.push(p_stream)
                    p_stream = ""
                end
            end
            found = true if r[0..8] == "#Message " && r[9..12] == message_id
            found = false if r == "#EndMessage\n"
        end
        f.close
        return stream
    end
    
    def initiate_minigame(lifes)
        return if @minigame_flag
        @minigame_flag = true
        @minigame_lifes = lifes
    end
    
    def determine_archetype(stats, difficulty)
        diff = ["Easy", "Normal", "Hard", "Doom"].index(difficulty)
        diff_arr = {Difficulty::EASY => 5, Difficulty::NORMAL => 4, Difficulty::HARD => 3, Difficulty::DOOM => 3}
        stat_energy = stats[Stats::Max_Energy] - (diff > Difficulty::EASY ? 3 : 4) + 0.1
        stat_lifes = stats[Stats::Max_Lifes] - diff_arr[diff] + 0.1
        stat_strength = stats[Stats::Strength] - 1 + 0.1
        stat_defense = stats[Stats::Defense] + 0.1
        
        stat_array = [stat_energy * HEDGE_ENERGY, stat_lifes * HEDGE_LIFES, stat_strength * HEDGE_STRENGTH, stat_defense * HEDGE_DEFENSE]
        index_array = [0, 1, 2, 3].sort_by{|i| stat_array[i]}
        stat_sum = stat_array[0] + stat_array[1] + stat_array[2] + stat_array[3]
        
        sorted_stats = stat_array.sort
        stat_ratio_1 = sorted_stats[-1] / stat_sum
        stat_ratio_2 = (sorted_stats[-1] + sorted_stats[-2]) / stat_sum
        
        max_ratio = index_array[-1]
        second_max_ratio = index_array[-2]
        max_ratios = [max_ratio, second_max_ratio].sort
        
        if stat_ratio_1 >= 0.75 then
            if max_ratio == 0 then
                return Archetypes::Bulky
            elsif max_ratio == 1 then
                return Archetypes::Pseudo_Cat
            elsif max_ratio == 2 then
                return Archetypes::Berserk
            elsif max_ratio == 3 then
                return Archetypes::Armored
            end
        elsif stat_ratio_2 >= 0.75 then
            if max_ratios == [0, 1] then
                return Archetypes::Relentless
            elsif max_ratios == [0, 2] then
                return Archetypes::Tank
            elsif max_ratios == [0, 3] then
                return Archetypes::Fortress
            elsif max_ratios == [1, 2] then
                return Archetypes::Glass_Cannon
            elsif max_ratios == [1, 3] then
                return Archetypes::Cautious
            elsif max_ratios == [2, 3] then
                return Archetypes::Stronghold
            end
        else
            return Archetypes::Balance
        end
        raise "Something went wrong while determining archetype."
    end
    
    def draw
        scale(1.0, 1.0) do
            if @nm then
                @test_img.draw(0, 0, 100)
            elsif @title_screen then
                @title_img.draw(0, 0, ZOrder::Background)
                @font.draw(Strings::Start_Game, 230, 300, ZOrder::UI_Extended, 2.0, 2.0, (@title_selection == 0 ? 0xff000000 : 0xff999999)) if milliseconds % 1000 >= (@title_selection == 0 ? 500 : 0)
                @font.draw(Strings::Achievements, 210, 350, ZOrder::UI_Extended, 2.0, 2.0, (@title_selection == 1 ? 0xff000000 : 0xff999999)) if milliseconds % 1000 >= (@title_selection == 1 ? 500 : 0)
            elsif @achievement_screen then
                @ach_img.draw(0, 0, ZOrder::Background)
                datas = []
                Dir.glob(Media::Folder_Players + "*.isf") do |f|
                    n = File.basename(f, ".isf")
                    state = load_state_in_hash(n)
                    datas.push([n, state])
                end
                if datas.size > 0 then
                    translate(0.0, -@achievement_scroller) do
                        @font.draw(Strings::Achievements, 20, 20, ZOrder::UI, 2.0, 2.0)
                        state = datas[@selected_achievement % datas.size]
                        progress = (state[1]["Cleared Levels"].size*100/51).to_i
                        shis = state[1]["Shi Coins"].size
                        score = state[1]["Presets"][1][Stats::Score]
                        beaten = state[1]["Cleared Levels"].index("5-10")
                        mysteriorbs = (state[1]["Other"] && state[1]["Other"][Other::Mysteriorb] ? state[1]["Other"][Other::Mysteriorb].size : 0)
                        compass_pieces = (state[1]["Other"] && state[1]["Other"][Other::Compass] ? state[1]["Other"][Other::Compass].size : 0)
                        statistics = (state[1]["Other"] && state[1]["Other"][Other::Statistics] ? state[1]["Other"][Other::Statistics] : {})
                        shi_butchered = (statistics[Statistics::Enemies_Jumped] ? statistics[Statistics::Enemies_Jumped] : 0)
                        perfect_levels = (statistics[Statistics::Level_Deaths] ? (statistics[Statistics::Level_Deaths].each_value.map{|v| v}).count(0) : 0)
                        max_combo = (statistics[Statistics::Max_Combo] ? statistics[Statistics::Max_Combo] : 0)
                        golden_chishi = (statistics[Statistics::Golden_Chishi] ? statistics[Statistics::Golden_Chishi] : 0)
                        diff = [Strings::Easy_R, Strings::Normal_R, Strings::Hard_R, Strings::Doom_R][state[1]["Difficulty"]]
                        perfect_minigames = (statistics[Statistics::Minigame_Ratings] ? statistics[Statistics::Minigame_Ratings].count {|e| e[1] == "A"} : 0)
                        
                        archetype = determine_archetype(state[1]["Presets"][1], diff)
                        
                        milestone_array = []
                        milestone_array[Milestones::Game_Done] = beaten
                        milestone_array[Milestones::Game_100_Percent] = progress >= 100
                        milestone_array[Milestones::All_Shi_Coins] = shis >= 142
                        milestone_array[Milestones::All_Compass_Pieces] = compass_pieces >= 4
                        milestone_array[Milestones::All_Mysteriorbs] = mysteriorbs >= 5
                        milestone_array[Milestones::Highscore] = score >= 1000000000
                        milestone_array[Milestones::Shi_Massacre] = shi_butchered >= 1000
                        milestone_array[Milestones::Invincible] = perfect_levels >= 50
                        milestone_array[Milestones::Combo_Breaker] = max_combo >= 30
                        milestone_array[Milestones::Gold_Eye] = golden_chishi >= 1
                        # Shi coins in every world:
                        # 1 - 24
                        # 2 - 28
                        # 3 - 28
                        # 4 - 26
                        # 5 - 36
                        @font.draw(state[0], 50, 90, ZOrder::UI, 1.0, 1.0, 0xff00ff00)
                        c = 130
                        @font.draw(Strings::A_Difficulty, 80, c, ZOrder::UI, 1.0, 1.0)
                        @font.draw(diff, 300, c, ZOrder::UI, 1.0, 1.0, 0xff00ffff)
                        c += 30
                        @font.draw(Strings::A_Archetype, 80, c, ZOrder::UI, 1.0, 1.0)
                        @font.draw(archetype[0], 300, c, ZOrder::UI, 1.0, 1.0, archetype[1])
                        c += 30
                        milestone = Milestones::Game_Done
                        @font.draw(Strings::A_Game_Beaten, 80, c, ZOrder::UI, 1.0, 1.0)
                        @font.draw((beaten ? Strings::Yes : Strings::No), 300, c, ZOrder::UI, 1.0, 1.0, (milestone_array[milestone] ? 0xffdddd00 : 0xff00ffff))
                        if milestone_array[milestone] then
                            @milestone_imgs[milestone].draw(50, c-2, ZOrder::UI)
                        else
                            @notyet_img.draw(50, c-2, ZOrder::UI)
                        end
                        c += 30
                        milestone = Milestones::Game_100_Percent
                        @font.draw(Strings::A_Game_Progress, 80, c, ZOrder::UI, 1.0, 1.0)
                        @font.draw(progress.to_s + "%", 300, c, ZOrder::UI, 1.0, 1.0, (milestone_array[milestone] ? 0xffdddd00 : 0xff00ffff))
                        if milestone_array[milestone] then
                            @milestone_imgs[milestone].draw(50, c-2, ZOrder::UI)
                        else
                            @notyet_img.draw(50, c-2, ZOrder::UI)
                        end
                        c += 30
                        milestone = Milestones::Highscore
                        @font.draw(Strings::A_Score, 80, c, ZOrder::UI, 1.0, 1.0)
                        @font.draw(score.to_s, 300, c, ZOrder::UI, 1.0, 1.0, (milestone_array[milestone] ? 0xffdddd00 : 0xff00ffff))
                        if milestone_array[milestone] then
                            @milestone_imgs[milestone].draw(50, c-2, ZOrder::UI)
                        else
                            @notyet_img.draw(50, c-2, ZOrder::UI)
                        end
                        c += 30
                        milestone = Milestones::All_Shi_Coins
                        @font.draw(Strings::A_Shi_Coins, 80, c, ZOrder::UI, 1.0, 1.0)
                        @font.draw(shis.to_s, 300, c, ZOrder::UI, 1.0, 1.0, (milestone_array[milestone] ? 0xffdddd00 : 0xff00ffff))
                        if milestone_array[milestone] then
                            @milestone_imgs[milestone].draw(50, c-2, ZOrder::UI)
                        else
                            @notyet_img.draw(50, c-2, ZOrder::UI)
                        end
                        c += 30
                        milestone = Milestones::All_Compass_Pieces
                        if compass_pieces > 0 then
                            @font.draw(Strings::A_Compass_Pieces, 80, c, ZOrder::UI, 1.0, 1.0)
                            @font.draw(compass_pieces.to_s, 300, c, ZOrder::UI, 1.0, 1.0, (milestone_array[milestone] ? 0xffdddd00 : 0xff00ffff))
                        else
                            @font.draw(Strings::Unknown, 80, c, ZOrder::UI, 1.0, 1.0, 0xff888888)
                        end
                        if milestone_array[milestone] then
                            @milestone_imgs[milestone].draw(50, c-2, ZOrder::UI)
                        else
                            @notyet_img.draw(50, c-2, ZOrder::UI)
                        end
                        c += 30
                        milestone = Milestones::All_Mysteriorbs
                        if mysteriorbs > 0 then
                            @font.draw(Strings::A_Mysteriorbs, 80, c, ZOrder::UI, 1.0, 1.0)
                            @font.draw(mysteriorbs.to_s, 300, c, ZOrder::UI, 1.0, 1.0, (milestone_array[milestone] ? 0xffdddd00 : 0xff00ffff))
                        else
                            @font.draw(Strings::Unknown, 80, c, ZOrder::UI, 1.0, 1.0, 0xff888888)
                        end
                        if milestone_array[milestone] then
                            @milestone_imgs[milestone].draw(50, c-2, ZOrder::UI)
                        else
                            @notyet_img.draw(50, c-2, ZOrder::UI)
                        end
                        c += 30
                        milestone = Milestones::Shi_Massacre
                        @font.draw(Strings::A_Smashed_Shi, 80, c, ZOrder::UI, 1.0, 1.0)
                        @font.draw(shi_butchered.to_s, 300, c, ZOrder::UI, 1.0, 1.0, (milestone_array[milestone] ? 0xffdddd00 : 0xff00ffff))
                        if milestone_array[milestone] then
                            @milestone_imgs[milestone].draw(50, c-2, ZOrder::UI)
                        else
                            @notyet_img.draw(50, c-2, ZOrder::UI)
                        end
                        c += 30
                        milestone = Milestones::Invincible
                        @font.draw(Strings::A_Perfect_Levels, 80, c, ZOrder::UI, 1.0, 1.0)
                        @font.draw(perfect_levels.to_s, 300, c, ZOrder::UI, 1.0, 1.0, (milestone_array[milestone] ? 0xffdddd00 : 0xff00ffff))
                        if milestone_array[milestone] then
                            @milestone_imgs[milestone].draw(50, c-2, ZOrder::UI)
                        else
                            @notyet_img.draw(50, c-2, ZOrder::UI)
                        end
                        c += 30
                        milestone = Milestones::Combo_Breaker
                        @font.draw(Strings::A_Highest_Combo, 80, c, ZOrder::UI, 1.0, 1.0)
                        @font.draw(max_combo.to_s, 300, c, ZOrder::UI, 1.0, 1.0, (milestone_array[milestone] ? 0xffdddd00 : 0xff00ffff))
                        if milestone_array[milestone] then
                            @milestone_imgs[milestone].draw(50, c-2, ZOrder::UI)
                        else
                            @notyet_img.draw(50, c-2, ZOrder::UI)
                        end
                        c += 30
                        milestone = Milestones::Gold_Eye
                        if milestone_array[milestone] then
                            @milestone_imgs[milestone].draw(50, c-2, ZOrder::UI)
                            @font.draw(Strings::A_Golden_Chishi, 80, c, ZOrder::UI, 1.0, 1.0)
                            @font.draw(golden_chishi.to_s, 300, c, ZOrder::UI, 1.0, 1.0, (milestone_array[milestone] ? 0xffdddd00 : 0xff00ffff))
                        else
                            @font.draw(Strings::Unknown, 80, c, ZOrder::UI, 1.0, 1.0, 0xff888888)
                        end
                        if milestone_array[milestone] then
                            @milestone_imgs[milestone].draw(50, c-2, ZOrder::UI)
                        else
                            @notyet_img.draw(50, c-2, ZOrder::UI)
                        end
                    end
                end
            elsif @name_input then
                @name_img.draw(0, 0, ZOrder::Background)
                if !@difficulty_input then
                    c = 0
                    Dir.glob(Media::Folder_Players + "*.isf") do |f|
                        n = File.basename(f, ".isf")
                        next if n.upcase.index(self.text_input.text.upcase) != 0
                        state = load_state_in_hash(n)
                        score = (state["Cleared Levels"].size*100/51).to_i
                        diff = [Strings::Easy_R, Strings::Normal_R, Strings::Hard_R, Strings::Doom_R][state["Difficulty"]]
                        shis = state["Shi Coins"].size
                        p = diff + " - " + (score).to_s+"% (" + shis.to_s + Strings::Shi_Coins + ")"
                        if(c - @name_input_scroller >= 0) then
                            @font.draw(n, 40, (c*40)+80 - @name_input_scroller*40, ZOrder::UI, 1.0, 1.0, (self.text_input.text.upcase == n.upcase ? 0xff00ff00 : 0xffffffff))
                            @font.draw(p, 60, (c*40)+100 - @name_input_scroller*40, ZOrder::UI, 1.0, 1.0, (score == 100 ? 0xffdddd00 : 0xff00ffff))
                        end
                        c += 1
                    end
                    @max_name_input_scroller = [c - 10, 0].max
                    @name_input_scroller = @max_name_input_scroller if @name_input_scroller > @max_name_input_scroller
                    @font.draw(Strings::Enter_Name, 0, 0, ZOrder::UI, 1.0, 1.0, 0xffffffff)
                    @name_field.draw
                else
                    @font.draw(Strings::Welcome + "#{@name}!", 0, 0, ZOrder::UI, 1.0, 1.0, 0xffffffff)
                    @font.draw(Strings::Select_Difficulty, 0, 20, ZOrder::UI, 1.0, 1.0, 0xffffffff)
                    @font.draw(Strings::Choice, 0, 40, ZOrder::UI, 1.0, 1.0, 0xffffffff)
                    if @difficulty_choice == 0 then
                        @easy_img.draw(200, 50, ZOrder::Tiles)
                    elsif @difficulty_choice == 1 then
                        @normal_img.draw(200, 50, ZOrder::Tiles)
                    elsif @difficulty_choice == 2 then
                        @hard_img.draw(200, 50, ZOrder::Tiles)
                    elsif @difficulty_choice == 3 then
                        @doom_img.draw(200, 50, ZOrder::Tiles)
                    end
                    @diff_names.each do |i,v|
                        if @difficulty_choice == i then
                            @font.draw(v, 50, 60+i*20, ZOrder::UI, 1.0, 1.0, 0xff3399ff)
                        else
                            @font.draw(v, 50, 60+i*20, ZOrder::UI, 1.0, 1.0, 0xff888888)
                        end
                    end
                end
            elsif @world_map then
                world = @level.split("-")[0]
                lv = @level.split("-")[0..1].join("-")
                if @draw_world_hud then
                    @font.draw(Level::Desc2[lv], 0, 0, ZOrder::UI, 1.5, 1.5)
                    @font.draw(Strings::H_Score + "#{@i_stats[Stats::Score]}", 0, 30, ZOrder::UI, 1.5, 1.5) if @i_stats[Stats::Score] > 0
                    @font.draw(Strings::H_Lifes + "#{@i_stats[Stats::Lifes]}", 0, 60, ZOrder::UI, 1.5, 1.5) if @i_stats[Stats::Lifes] > 0
                    @font.draw(Strings::H_Coins + "#{@i_collectibles[Objects::Coin]} / 100", 460, 0, ZOrder::UI, 1.5, 1.5, 0xffffff00)
                    @font.draw(Strings::H_Gems + "#{@i_collectibles[Objects::Gem]}", 460, 30, ZOrder::UI, 1.5, 1.5, 0xffff00dd) if @i_collectibles[Objects::Gem] > 0
                    @font.draw(Strings::H_Shi_Coins + "#{@i_collectibles[Objects::Shi_Coin]}", 460, 60, ZOrder::UI, 1.5, 1.5, 0xffffdd00) if @collected_shi_coins.size > 0
                    if Minigames::World_Level_ID.index(lv) then
                        oop = other_option_param(Other::Statistics, Statistics::Minigame_Ratings, {})[convert_level_to_array(@level)[0..1]]
                        if oop then
                            @font.draw(Strings::H_Highscore + "#{oop[0]}", 0, 120, ZOrder::UI, 1.5, 1.5, 0xffffffff)
                            @font.draw(Strings::H_Rating + oop[1], 0, 150, ZOrder::UI, 1.5, 1.5, 0xffffffff)
                        end
                    end
                    if @i_collectibles[Objects::Gem] >= GEM_LIFES_1 then
                        @font.draw(" #{GEM_LIFES_1} " + Strings::Gem_Select, 370, 460, ZOrder::UI, 1.0, 1.0, 0xffff00dd)
                        @font.draw("1" + Strings::Gem_Life, 480, 460, ZOrder::UI, 1.0, 1.0, 0xffff00dd)
                        @font.draw(Strings::Gem_Press + "'1'", 565, 460, ZOrder::UI, 1.0, 1.0, 0xffffffff)
                    end
                    if @i_collectibles[Objects::Gem] >= GEM_LIFES_3 then
                        @font.draw(" #{GEM_LIFES_3} " + Strings::Gem_Select, 370, 440, ZOrder::UI, 1.0, 1.0, 0xffff00dd)
                        @font.draw("3" + Strings::Gem_Lifes, 480, 440, ZOrder::UI, 1.0, 1.0, 0xffff00dd)
                        @font.draw(Strings::Gem_Press + "'2'", 565, 440, ZOrder::UI, 1.0, 1.0, 0xffffffff)
                    end
                    if @i_collectibles[Objects::Gem] >= GEM_LIFES_5 then
                        @font.draw(" #{GEM_LIFES_5} " + Strings::Gem_Select, 370, 420, ZOrder::UI, 1.0, 1.0, 0xffff00dd)
                        @font.draw("5" + Strings::Gem_Lifes, 480, 420, ZOrder::UI, 1.0, 1.0, 0xffff00dd)
                        @font.draw(Strings::Gem_Press + "'3'", 565, 420, ZOrder::UI, 1.0, 1.0, 0xffffffff)
                    end
                    if @i_collectibles[Objects::Gem] >= GEM_LIFES_10 then
                        @font.draw(" #{GEM_LIFES_10} " + Strings::Gem_Select, 370, 400, ZOrder::UI, 1.0, 1.0, 0xffff00dd)
                        @font.draw("10" + Strings::Gem_Lifes, 480, 400, ZOrder::UI, 1.0, 1.0, 0xffff00dd)
                        @font.draw(Strings::Gem_Press + "'4'", 565, 400, ZOrder::UI, 1.0, 1.0, 0xffffffff)
                    end
                    if @i_collectibles[Objects::Gem] >= GEM_LIFES_100 then
                        @font.draw("#{GEM_LIFES_100}" + Strings::Gem_Select, 370, 380, ZOrder::UI, 1.0, 1.0, 0xffff00dd)
                        @font.draw("100" + Strings::Gem_Lifes, 480, 380, ZOrder::UI, 1.0, 1.0, 0xffff00dd)
                        @font.draw(Strings::Gem_Press + "'5'", 565, 380, ZOrder::UI, 1.0, 1.0, 0xffffffff)
                    end
                end
                @world_map_img.draw(0, 0, ZOrder::Background)
                @world_inuhh.draw
                Level::Positions.each do |p,q|
                    levelseg = p.split("-")
                    if world == levelseg[0] then
                        if Minigames::World_Level_ID.index(p) then
                            @world_icons[Level::Symbols[p]].draw(q[0], q[1]-25, ZOrder::Tiles)
                            @level_index_minigame.draw(q[0], q[1], ZOrder::Warps)
                            oop = other_option_param(Other::Statistics, Statistics::Minigame_Ratings, {})[levelseg[0..1]]
                            if oop then
                                @font.draw(oop[1], q[0] + 6, q[1] + 2, ZOrder::Gems, 1.0, 1.0, 0xffffff00)
                            end
                        elsif @cleared_levels.index(p) then
                            @world_icons[Level::Symbols[p]].draw(q[0], q[1]-25, ZOrder::Tiles)
                            @level_index_cleared.draw(q[0], q[1], ZOrder::Warps)
                            counter = 0
                            @collected_shi_coins.each do |c,d|
                                if d && c[0].split("-")[0..1].join("-") == p then
                                    counter += 1
                                end
                            end
                            coin_number_color = (Level::Number[p] == counter ? 0xffffff00 : 0xffffffff)
                            @font.draw(counter, q[0]+8-(counter > 9 ? 5 : 0), q[1]+2, ZOrder::Gems, 1.0, 1.0, coin_number_color) if counter > 0
                            if @other && @other[Other::Statistics] && @other[Other::Statistics][Statistics::Level_Deaths] then
                                os = @other[Other::Statistics][Statistics::Level_Deaths][levelseg]
                                @perfect_level.draw(q[0]-8, q[1], ZOrder::Gems) if os == 0
                            end
                        elsif @unlocked_levels.index(p) then
                            @world_icons[Level::Symbols[p]].draw(q[0], q[1]-25, ZOrder::Tiles)
                            @level_index.draw(q[0], q[1], ZOrder::Warps)
                        end
                    end
                    offsets = [[7, 25], [-10, 7], [25, 7], [7, -35]]
                    0.upto(3) do |c|
                        conn = Level::Connections[p][c]
                        if conn && @unlocked_levels.index(conn) && @cleared_levels.index(p) then
                            r = Level::Positions[conn]
                            @arrows[c].draw(q[0]+offsets[c][0], q[1]+offsets[c][1], ZOrder::Gems) if world == levelseg[0]
                            @arrows[3-c].draw(r[0]+offsets[3-c][0], r[1]+offsets[3-c][1], ZOrder::Gems) if conn.split("-")[0] == world
                            line_color = ((!Level::Story.index(p) || !Level::Story.index(conn)) ? 0xff000000 : 0xffffffff)
                            draw_line(q[0]+12, q[1]+12, line_color, r[0]+12, r[1]+12, line_color, ZOrder::Behind_Tiles) if world == levelseg[0] && conn.split("-")[0] == world
                        end
                    end
                end
                if @minigame_confirmation then
                    @textbox.draw(50, 195, ZOrder::UI, 1.8, 1.0)
                    gem_cost = Minigames::Gem_Cost[Minigames::World_Levels[@level.split("-")[0].to_i]]
                    @font.draw(Strings::M_Gems_Needed + gem_cost.to_s + Strings::M_Gems_Needed_2, 60, 200, ZOrder::UI_Extended, 2.0, 2.0, 0xffff00ff)
                    if @i_collectibles[Objects::Gem] >= gem_cost then
                        @font.draw(Strings::M_Gems_Okay, 60, 250, ZOrder::UI_Extended, 2.0, 2.0, 0xff00ff00)
                    else
                        @font.draw(Strings::M_Gems_Not_Okay, 60, 250, ZOrder::UI_Extended, 2.0, 2.0, 0xffff0000)
                    end
                end
            elsif @credits then
                @credits_img.draw(0, 0, ZOrder::Background)
                fintext = Final.fin_text_cache
                c = 0
                textcolor = 0xffffffff

                (0 + @credits).to_i.upto((30 + @credits).to_i) do |f_i|
                    next if f_i >= fintext.size
                    f = fintext[f_i]
                    if f.index("#") then
                        textcolor = 0xff00ffff
                        f.gsub!("#","")
                    end
                    if f.index("$") then
                        textcolor = 0xffff0000
                        f.gsub!("$","")
                    end
                    @font.draw(f.strip, 10, 20+c*20-(20*@credits % 20).to_i, ZOrder::UI, 1.0, 1.0, textcolor)
                    c += 1
                    textcolor = 0xffffffff
                end
            else
                translate((-@camera_x/10).floor, (-@camera_y/10).floor) do
                    @sky.draw(0, @map.height*5-2000+480, ZOrder::Background) if !@halted
                end
                translate((-@camera_x/5).floor, (-@camera_y/5).floor) do
                    @special.draw(0, @map.height*5-1000+480, ZOrder::Foreground) if @special && !@halted
                end
                @drunken_picture.draw(0, 0, ZOrder::Foreground, 1.0, 1.0, 0xff000000 + (Math::cos(milliseconds/2000)**2*0x000000ff).to_i) if @inuhh && @inuhh.drunken
                if @debug_console then
                    @debug_field.draw
                end
                translate(-@camera_x, -@camera_y) do
                    @map.draw((@camera_x/50).floor, (@camera_y/50).floor) if !@halted
                    @map.warps.each { |w| w.draw }
                    @entity_triggers.each { |t| t.draw }
                    @gems.each { |g| g.draw }
                    @spawners.each { |s| s.draw }
                    @signposts.each { |p| p.draw }
                    @residues.reject! do |r|
                        r.draw
                        r.counter -= 1 if !@halted && !@semi_halted
                        r.counter == 0
                    end
                    @enemies.each do |e|
                        e.draw
                        if e.boss then
                            @boss_bar.draw(e.x-e.xsize, e.y-2*e.ysize-20, ZOrder::UI, e.xsize/25.0*e.hp.to_f/e.maxhp, 1.0)
                            @font.draw(Enemy_Datas.n_index[Enemy_Datas.c_index.index(e.class)], e.x-e.xsize, e.y-2*e.ysize-40, ZOrder::UI, 1.0, 1.0, 0xffff0000)
                        end
                    end
                    @inuhh.draw
                    @projectiles.each { |p| p.draw }
                    @messages.reject! do |m|
                        @font.draw("#{m[0]}", m[1], m[2], ZOrder::UI, [m[5],5.0].min, [m[6],5.0].min, m[7])
                        m[3] -= 1 if !@halted && !@semi_halted
                        m[2] -= 1 if m[4] && !@halted && !@semi_halted
                        m[3] == 0 # Delete entry if counter ran out
                    end
                    
                    bbc = 0
                    @boost_bars.each do |b|
                        if b then
                            ind = @boost_bars.index(b)
                            b.draw(@inuhh.x-25, @inuhh.y-50+bbc*5, ZOrder::UI, @inuhh.boosts[ind][1].to_f/@inuhh.boosts[ind][2], 1.0) if @inuhh.boosts[ind][2] != 0
                            bbc += 1
                        end
                    end
                end
                if @minigame_flag then
                    if @minigame_lifes < 6 then
                        0.upto(@minigame_lifes - 1) do |h|
                            @minigame_life.draw(10+h*20, 400, ZOrder::UI)
                        end
                    else
                        @minigame_life.draw(10, 400, ZOrder::UI)
                        @font.draw("x #{@minigame_lifes}", 35, 400, ZOrder::UI)
                    end
                else
                    @lifes_to_draw = @inuhh.stats[Stats::Lifes]
                    if @lifes_to_draw < 6 then
                        0.upto(@lifes_to_draw - 1) do |h|
                            @life.draw(10+h*20, 400, ZOrder::UI)
                        end
                    else
                        @life.draw(10, 400, ZOrder::UI)
                        @font.draw("x #{@lifes_to_draw}", 35, 400, ZOrder::UI)
                    end
                end
                0.upto(@inuhh.stats[Stats::Energy]-1) do |h|
                    @energy.draw(10+h*10, 425, ZOrder::UI)
                end
                
                @font.draw("K.", 150, 100, ZOrder::UI, 10.0, 10.0, 0xffff0000) if @death_timer <= 50 && @death_timer > 0
                @font.draw("O.", 350, 100, ZOrder::UI, 10.0, 10.0, 0xffff0000) if @death_timer <= 30 && @death_timer > 0
                
                @font.draw("STATS", 580, 400, ZOrder::UI, 1.0, 1.0, 0xffffffff)
                0.upto(@inuhh.stats[Stats::Strength]+@inuhh.boosts[Stats::Strength][0]-1) do |h|
                    @strength.draw(620-h*10, 425, ZOrder::UI)
                end
                0.upto(@inuhh.stats[Stats::Defense]-1) do |h|
                    @defense.draw(620-h*10, 440, ZOrder::UI)
                end
                @font.draw(Strings::Paused, 10, 375, ZOrder::UI, 1.0, 1.0, 0xffff0000) if @halted && milliseconds % 1000 > 500
                score_to_draw = (@minigame_flag ? @minigame_score : @inuhh.stats[Stats::Score])
                @font.draw("#{score_to_draw}", 10, 440, ZOrder::UI, 1.0, 1.0, 0xffffff00)
                @font.draw(Strings::Main_Coins + "#{@inuhh.collectibles[Objects::Coin]} / 100", 10, 460, ZOrder::UI, 1.0, 1.0, 0xffff9900) if !@minigame_flag
                @textbox.draw(0, 0, ZOrder::UI) if @map_display > 0 || @halted
                @font.draw(Level::Desc[@level], 10, 30, ZOrder::UI_Extended, 1.5, 1.5, 0x99ffffff) if @map_display > 0 || @halted
                if @text && !@display_wait then
                    @semi_halted = true
                    @display_text = @text.first
                    @text.delete(@display_text)
                    @display_wait = true
                    @text = nil if @text.empty?
                elsif @end_text && !@display_wait then
                    @semi_halted = true
                    @display_text = @end_text[0]
                    @end_text = nil
                    @display_wait = true
                elsif !@display_wait && @death_timer == 0 then
                    @semi_halted = false
                end
                if @display_wait && @display_text then
                    if @hedgehound then
                        sc = @inuhh.collectibles[Objects::Shi_Coin]
                        @shopbox.draw(0, 0, ZOrder::UI)
                        @font.draw(Strings::Hedge_Shop, 245, 60, ZOrder::UI_Extended, 2.0, 2.0, 0xffffffff)
                        @font.draw(Strings::Hedge_Energy, 60, 120, ZOrder::UI_Extended, 1.5, 1.5, 0xffffffff)
                        @font.draw("(#{hedge_energy}" + Strings::Hedge_Shi_Coins, 400, 120, ZOrder::UI_Extended, 1.5, 1.5, (sc >= hedge_energy ? 0xff00ff00 : 0xffff0000))
                        @font.draw(Strings::Hedge_Lifes, 60, 150, ZOrder::UI_Extended, 1.5, 1.5, 0xffffffff)
                        @font.draw("(#{hedge_lifes}" + Strings::Hedge_Shi_Coins, 400, 150, ZOrder::UI_Extended, 1.5, 1.5, (sc >= hedge_lifes ? 0xff00ff00 : 0xffff0000))
                        @font.draw(Strings::Hedge_Strength, 60, 180, ZOrder::UI_Extended, 1.5, 1.5, 0xffffffff)
                        @font.draw("(#{hedge_strength}" + Strings::Hedge_Shi_Coins, 400, 180, ZOrder::UI_Extended, 1.5, 1.5, (sc >= hedge_strength ? 0xff00ff00 : 0xffff0000))
                        @font.draw(Strings::Hedge_Defense, 60, 210, ZOrder::UI_Extended, 1.5, 1.5, 0xffffffff)
                        @font.draw("(#{hedge_defense}" + Strings::Hedge_Shi_Coins, 400, 210, ZOrder::UI_Extended, 1.5, 1.5, (sc >= hedge_defense ? 0xff00ff00 : 0xffff0000))
                        @font.draw(Strings::Hedge_Own_Shi_Coins + "#{sc}", 400, 380, ZOrder::UI_Extended, 1.5, 1.5, 0xffffff00)
                        mysteriorbs = (other_option(Other::Mysteriorb) ? other_option(Other::Mysteriorb).size : 0)
                        if mysteriorbs >= 5 && WORLD_6_ALLOWED then
                            @font.draw(WORLD_6_DIALOG, 60, 240, ZOrder::UI_Extended, 1.5, 1.5, 0xffffffff)
                            @font.draw(Strings::Hedge_Mysteriorbs, 400, 240, ZOrder::UI_Extended, 1.5, 1.5, 0xff00ff00)
                        elsif mysteriorbs >= 1 && WORLD_6_ALLOWED then
                            @font.draw(WORLD_6_U_DIALOG, 60, 240, ZOrder::UI_Extended, 1.5, 1.5, 0xffffffff)
                            @font.draw(Strings::Hedge_Unknown_Mysteriorbs, 400, 240, ZOrder::UI_Extended, 1.5, 1.5, 0xffff0000)
                        end
                    elsif @display_text[0] == "@" then
                        @font.draw(@display_text[1..-1], 50, 0, ZOrder::UI_Extended, 4.0, 4.0, 0xffff0000)
                        @font.draw(Strings::Continue, 120, 100, ZOrder::UI_Extended, 2.0, 2.0, 0xffff0000) if milliseconds % 2000 < 1000
                    else
                        @signbox.draw(0, 0, ZOrder::UI)
                        c = 0
                        @font.draw(Strings::Info, 250, 60, ZOrder::UI_Extended, 2.0, 2.0, 0xffffffff)
                        @display_text.split("\n").each do |d|
                            @font.draw(d, 60, 120+c*30, ZOrder::UI_Extended, 1.5, 1.5, 0xffffffff)
                            c+=1
                        end
                    end
                end
                @font.draw(Strings::Loading, 0, 0, ZOrder::UI_Extended) if @load_map[0] && !@semi_halted
            end
        end
    end
    
    def button_down(id) # Some self-references here... maybe?
        if id == KbEscape then
            deactivate_debug # Important!
            if @hedgehound then # Kill without Game Over Message
                @semi_halted = false
                @display_wait = false
                @load_map = [true, nil]
                @death_counter = 0
                @maps = {}
                change_world_img(@level.split("-")[0])
                @text_flag = false
                @gameover_flag = true
            elsif @title_screen then
                close
            elsif @name_input || (@world_map && !@minigame_confirmation) then
                self.text_input = nil
                @name_input = false
                @achievement_screen = false
                @title_screen = true
                @selected_achievement = 0
                @achievement_scroller = 0
            elsif @minigame_confirmation && @world_map then
                @minigame_confirmation = false
            elsif @death_timer > 0 then
                @death_timer = 1
            elsif @semi_halted then # Only kill the textbox
                @display_wait = false
                @display_text = ""
                @text = nil
                @semi_halted = false
            elsif @halted then # Suicide
                @halted = !@halted if !@semi_halted
                if @minigame_flag then
                    @minigame_lifes = 0
                else
                    @inuhh.suicide
                end
            elsif @credits then
                @credits = false
            else
                if @minigame_flag then
                    @minigame_lifes = 0
                else
                    @inuhh.suicide
                end
            end
        end
        if @credits then
            if id == KbDown then
                @credits += 5
            end
            if id == KbUp then
                @credits -= 5
                @credits = 0 if @credits < 0
            end
        end
        if @title_screen then
            if id == KbReturn then
                if @title_selection == 0 then
                    switch_to_name_selection
                else
                    @achievement_screen = true
                    @title_screen = false
                end
            end
            if id == KbUp || id == KbW then # If more options are added, this has to be rewritten.
                @title_selection = 0
            end
            if id == KbDown || id == KbS then
                @title_selection = 1
            end
        elsif @name_input then
            if @difficulty_input then
                if id == KbDown || id == KbS then
                    @difficulty_choice += 1 if @difficulty_choice < @diff_names.size-1
                end
                if id == KbUp || id == KbW then
                    @difficulty_choice -= 1 if @difficulty_choice > 0
                end
                if id == KbReturn then
                    Difficulty.set(@difficulty_choice)
                    @name_input = false
                    @difficulty_input = false
                end
            elsif id == KbReturn && @name_field.text != "" && !@difficulty_input then
                load_name_file(self.text_input.text)
            end
        elsif @achievement_screen then
            if id == KbLeft || id == KbA then
                @selected_achievement -= 1
            elsif id == KbRight || id == KbD then
                @selected_achievement += 1
            end
        elsif @world_map then
            if id == KbSpace then
                @draw_world_hud = !@draw_world_hud
            end
            if (id == Kb1) && @i_collectibles[Objects::Gem] >= GEM_LIFES_1 then
                @i_collectibles[Objects::Gem] -= GEM_LIFES_1
                @i_stats[Stats::Lifes] += 1
            end
            if (id == Kb2) && @i_collectibles[Objects::Gem] >= GEM_LIFES_3 then
                @i_collectibles[Objects::Gem] -= GEM_LIFES_3
                @i_stats[Stats::Lifes] += 3
            end
            if (id == Kb3) && @i_collectibles[Objects::Gem] >= GEM_LIFES_5 then
                @i_collectibles[Objects::Gem] -= GEM_LIFES_5
                @i_stats[Stats::Lifes] += 5
            end
            if (id == Kb4) && @i_collectibles[Objects::Gem] >= GEM_LIFES_10 then
                @i_collectibles[Objects::Gem] -= GEM_LIFES_10
                @i_stats[Stats::Lifes] += 10
            end
            if (id == Kb5) && @i_collectibles[Objects::Gem] >= GEM_LIFES_100 then
                @i_collectibles[Objects::Gem] -= GEM_LIFES_100
                @i_stats[Stats::Lifes] += 100
            end
            if id == KbReturn then
                if Minigames::World_Level_ID.index(@level.split("-")[0..1].join("-")) then
                    if !@minigame_confirmation then
                        @minigame_confirmation = true
                    else
                        gem_cost = Minigames::Gem_Cost[Minigames::World_Levels[@level.split("-")[0].to_i]]
                        if @i_collectibles[Objects::Gem] >= gem_cost || Debug::ON
                            @i_collectibles[Objects::Gem] -= gem_cost
                            @reload = true
                            @minigame_confirmation = false
                            @world_map = false
                            @cleared = false
                            @load_map = [true, @coords]
                        else
                            #TODO: Play some sound
                            @minigame_confirmation = false
                        end
                    end
                else
                    @reload = true
                    @world_map = false
                    @cleared = false
                    @load_map = [true, @coords]
                end
            end
            button_index = nil
            if id == KbDown || id == KbS then
                button_index = 0
            elsif id == KbLeft || id == KbA then
                button_index = 1
            elsif id == KbRight || id == KbD then
                button_index = 2
            elsif id == KbUp || id == KbW then
                button_index = 3
            end
            if button_index && !@minigame_confirmation then
                lv = @level.split("-")[0..1].join("-")
                if Level::Connections[lv][button_index] && @cleared_levels.index(lv) && @unlocked_levels.index(Level::Connections[lv][button_index]) then
                    @level = Level::Connections[lv][button_index]+"-1"
                    change_world_img(@level.split("-")[0])
                else
                    Level::Connections.each do |p,q|
                        if q[3-button_index] == lv && @unlocked_levels.index(p) && @cleared_levels.index(p) then
                            @level = p+"-1"
                            change_world_img(@level.split("-")[0])
                        end
                    end
                end
            end
        else
            if @hedgehound then
                sc = @inuhh.collectibles[Objects::Shi_Coin]
                mysteriorbs = (other_option(Other::Mysteriorb) ? other_option(Other::Mysteriorb).size : 0)
                if id == Kb1 && sc >= hedge_energy then
                    @inuhh.pay_shi_coins(hedge_energy)
                    @inuhh.increase_stat(Stats::Max_Energy, 1)
                    @inuhh.heal
                elsif id == Kb2 && sc >= hedge_lifes  then
                    @inuhh.pay_shi_coins(hedge_lifes)
                    @inuhh.increase_stat(Stats::Max_Lifes, 1)
                    @inuhh.increase_stat(Stats::Lifes, 1)
                elsif id == Kb3 && sc >= hedge_strength  then
                    @inuhh.pay_shi_coins(hedge_strength)
                    @inuhh.increase_stat(Stats::Strength, 1)
                elsif id == Kb4 && sc >= hedge_defense then
                    @inuhh.pay_shi_coins(hedge_defense)
                    @inuhh.increase_stat(Stats::Defense, 1)
                elsif id == Kb5 && mysteriorbs >= 5 && WORLD_6_ALLOWED then
                    @unlocked_levels.push("6-1") if !@unlocked_levels.index("6-1")
                    @level = "6-1-1"
                    change_world_img(@level.split("-")[0])
                    @text_flag = true if !@display_wait
                    @display_wait = false
                    save_state
                end
            end
            if id == KbSpace then
                @inuhh.use_item if !@halted && !@semi_halted
            end
            
            if id == KbP then
                @halted = !@halted if !@semi_halted && !@debug_console
            end
            
            if Debug::ON then	# Debug console
                if id == KbF12 then
                    if @debug_console then
                        deactivate_debug
                    else
                        activate_debug
                    end
                end
            end
            
            if id == KbF1 then
                if @minigame_flag then
                    @text = import_message(Minigames::Help_Entry[Minigames::World_Levels[@level.split("-")[0].to_i]])
                end
                if @inuhh.item && @inuhh.item.help && !@semi_halted then
                    if @text then
                        @text += import_message(@inuhh.item.help)
                    else
                        @text = import_message(@inuhh.item.help)
                        @text_flag = false
                    end
                end
                if @inuhh.riding_entity then
                    message_id = nil  # Could be solved better with enemy-internal values
                    message_id = 54 if @inuhh.riding_entity.is_a? Shirse
                    message_id = 61 if @inuhh.riding_entity.is_a? Turboshi
                    if @text then
                        @text += import_message(message_id) if message_id
                    else
                        @text = import_message(message_id) if message_id
                    end
                end
            end
            
            if id == KbF2 && Debug::ON then
                shield_break
            end
            
            if id == KbReturn then
                if @debug_console then
                    cmd = self.text_input.text
                    error = nil
                    break_flag = true
                    cmds = cmd.split(" ")
                    if cmds[0][0] == "!" then
                        break_flag = false
                        cmds[0] = cmds[0][1..-1]
                    end
                    2.upto(cmds.size-1) do |i|
                        if cmds[i].upcase == "TRUE" then
                            cmds[i] = true
                        elsif cmds[i].upcase == "FALSE" then
                            cmds[i] = false
                        elsif cmds[i][0] == "#" then
                            cmds[i] = cmds[i][1..-1].to_f
                            if cmds[i] == cmds[i].to_i then
                                cmds[i] = cmds[i].to_i
                            end
                        end
                    end
                    if cmds[0][0].upcase == "D" && cmds[0][1..-1].to_i > 0 && cmds[1].nil? then
                        cmds[1] = cmds[0][1..-1]
                        cmds[0] = "DEBUG"
                    end
                    if cmds[0].upcase == "ECHO" then
                        if cmds[1].nil? then
                            error = "Argument Error"
                        elsif cmds[1][0] == "@" then
                            if instance_variable_defined?("@#{cmds[1][1..-1]}") then
                                Debug.output(instance_variable_get("@#{cmds[1][1..-1]}").to_s)
                            else
                                error = "Variable Error"
                            end
                        elsif cmds[1][0] == "$" then
                            if @inuhh.instance_variable_defined?("@#{cmds[1][1..-1]}") then
                                Debug.output(@inuhh.instance_variable_get("@#{cmds[1][1..-1]}").to_s)
                            else
                                error = "Variable Error"
                            end
                        else
                            Debug.output(cmds[1..-1].join(" "))
                        end
                    elsif cmds[0].upcase == "SET" then
                        if cmds[1].nil? || cmds[2].nil? then
                            error = "Argument Error"
                        elsif cmds[1][0] == "@" then
                            if instance_variable_defined?("@#{cmds[1][1..-1]}") then
                                instance_variable_set("@#{cmds[1][1..-1]}", cmds[2])
                            else
                                error = "Variable Error"
                            end
                        elsif cmds[1][0] == "$" then
                            if @inuhh.instance_variable_defined?("@#{cmds[1][1..-1]}") then
                                @inuhh.instance_variable_set("@#{cmds[1][1..-1]}", cmds[2])
                            else
                                error = "Variable Error"
                            end
                        end
                    elsif cmds[0].upcase == "APPLY" then
                        if cmds[1].nil? || cmds[2].nil? then
                            error = "Argument Error"
                        elsif cmds[1][0] == "@" then
                            if instance_variable_defined?("@#{cmds[1][1..-1]}") then
                                if !instance_variable_get("@#{cmds[1][1..-1]}").respond_to?(cmds[2]) then
                                    error = "Name Error"
                                elsif instance_variable_get("@#{cmds[1][1..-1]}").method(cmds[2]).arity != -1 && instance_variable_get("@#{cmds[1][1..-1]}").method(cmds[2]).arity != cmds.size-3 then
                                    error = "Argument Error"
                                else
                                    instance_variable_get("@#{cmds[1][1..-1]}").send(cmds[2], *cmds[3..-1])
                                end
                            else
                                error = "Variable Error"
                            end
                        elsif cmd[1][0] == "$" then
                            if @inuhh.instance_variable_defined?("@#{cmds[1][1..-1]}") then
                                if !@inuhh.instance_variable_get("@#{cmds[1][1..-1]}").respond_to?(cmds[2]) then
                                    error = "Name Error"
                                elsif @inuhh.instance_variable_get("@#{cmds[1][1..-1]}").method(cmds[2]).arity != -1 && @inuhh.instance_variable_get("@#{cmds[1][1..-1]}").method(cmds[2]).arity != cmds.size-3 then
                                    puts cmds.size-3
                                    error = "Argument Error"
                                else
                                    @inuhh.instance_variable_get("@#{cmds[1][1..-1]}").send(cmds[2], *cmds[3..-1])
                                end
                            else
                                error = "Variable Error"
                            end
                        end
                    elsif cmds[0].upcase == "EXIT" then
                        break_flag = true
                    elsif cmds[0].upcase == "DEBUG" then
                        if cmds[1].nil? then
                            error = "Argument Error"
                        else
                            if cmds[1].upcase == "SHICOINS" || cmds[1] == "1" then
                                @inuhh.pay_shi_coins(-100)
                            elsif cmds[1].upcase == "SPEED" || cmds[1] == "2" then
                                @debug_speed_flag = !@debug_speed_flag
                            elsif cmds[1].upcase == "INVINCIBLE" || cmds[1] == "3" then
                                @debug_invincible_flag = !@debug_invincible_flag
                            elsif cmds[1].upcase == "STRENGTH" || cmds[1] == "4" then
                                @debug_strength_flag = !@debug_strength_flag
                            elsif cmds[1].upcase == "FLY" || cmds[1] == "5" then
                                @inuhh.toggle_fly
                            elsif cmds[1].upcase == "DETONATION" || cmds[1] == "6" then
                                @enemies.each do |e|
                                    e.detonate
                                end
                            elsif cmds[1].upcase == "DEFENSE" || cmds[1] == "7" then
                                @inuhh.increase_stat(Stats::Defense, 10) # Toggle!
                            elsif cmds[1].upcase == "LIFES" || cmds[1] == "8" then
                                @inuhh.increase_stat(Stats::Lifes, 100)
                                @inuhh.increase_stat(Stats::Max_Lifes, 100)
                            elsif cmds[1].upcase == "CHAOS" || cmds[1] == "9" then
                                @debug_chaos_flag = !@debug_chaos_flag
                            elsif cmds[1].upcase == "HUNTING" || cmds[1] == "10" then
                                @enemies.each do |e|
                                    e.chase_inuhh
                                end
                            elsif cmds[1].upcase == "SPECIAL" || cmds[1] == "11" then
                                @inuhh.toggle_fly
                                @inuhh.increase_stat(Stats::Defense, 10) # Toggle!
                                @inuhh.increase_stat(Stats::Lifes, 100)
                                @inuhh.increase_stat(Stats::Max_Lifes, 100)
                            else
                                error = "Name Error"
                            end
                        end
                    else
                        error = "Command Error"
                    end
                    if error then
                        Debug.output(error)
                    end
                    self.text_input.text = ""
                    deactivate_debug if break_flag
                elsif @death_timer == 0
                    @text_flag = true if !@display_wait
                    @display_wait = false
                    if @hedgehound then
                        save_state
                    end
                end
            else
                @text_flag = false
            end
        end
    end
    
end

begin
    
    Game.new.show
    
rescue Exception => exc
    
    f = File.open("log.txt", "a")
    f.puts "Error in Inuhh.rb at #{Time.now}:"
    f.puts exc.inspect
    f.puts exc.backtrace
    f.puts ""
    f.close
    raise exc
    
end
