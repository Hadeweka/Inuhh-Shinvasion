class Adm_Aromtharag < Enemy
    
    def activation
        @strength = 4
        @score = 1000000
        @speed = 4
        @defense = 0
        @reduction = 1
        @range = 10000
        @world = 5
        @play_charge_sound = 20
        @shield_counter = 0
        @dodge = false
        @shield_image = Image.new("media/special/Shield2525.png", tileable: true)
        hpdiff = [20, 25, 30, 35]
        @maxhp = hpdiff[Difficulty.get]
        @hp = hpdiff[Difficulty.get]
        @boss = true
        @healing_counter = (Difficulty.get > Difficulty::EASY ? (Difficulty.get > Difficulty::NORMAL ? 2 : 1) : 0)
        @hunting = true
        @hunt_max_delay = 60
        @troop_value = 0
        @troops = []
        @mindamage = 2
        @projectile = false
        @border_turn = false
        @abyss_turn = false
        @projectile = true
        @drop = Objects::Key
        @projectile_reload = (Difficulty.get > Difficulty::NORMAL ? 137 : 217)
        @projectile_damage = 4
        @projectile_type = Projectiles::Laser
        @projectile_offset = [0.0, -@ysize+3.0]
        @projectile_mechanics = [0.0, 0.0, 0.0, 0.0]
        load_graphic("Adm_Aromtharag", 2*@xsize)
        @description = "The admiral of the Shi invadors and also one
        of the strongest Shi. Can summon various other
        Shi units, can protect itself with a shield and
        shoots back if shot frontally. Also can heal
        itself and will jump around if damaged heavily.
        Resides on the Yunada Bridge."
    end
    
    def shoot_projectile
        return if @dir == :left && @inuhh.x > @x || @dir == :right && @inuhh.x < @x
        @speed = 0
        restore_vy = @vy
        @vy = 0
        dvecx = @inuhh.x - (@x + (@dir == :left ? -@xsize : @xsize))
        dvecy = @inuhh.y - (@y - 2*@ysize + 3.0)
        cosphi = ((@dir == :left ? -1.0 : 1.0)*dvecx / Math::sqrt(dvecx*dvecx + dvecy*dvecy))
        projx = cosphi*10.0
        projy = (@inuhh.y < @y ? -1.0 : 1.0)*Math::sqrt(1-cosphi*cosphi)*(10.0+rand(5)*1.0)
        @projectile_mechanics = [projx, projy, 0.0, 0.0]
        super()
        @vy = restore_vy
        @speed = (@shield_counter > 0 ? 1 : 4)
    end
    
    def at_shot(projectile)
        a = (projectile.vx > 0 && @dir == :right) || (projectile.vx < 0 && @dir == :left)
        @dir = (@inuhh.x < @x ? :left : :right)
        shoot_projectile if !a && projectile.owner == Projectiles::INUHH
        return a
    end
    
    def draw
        super()
        @shield_image.draw(@x-@xsize-25, @y-2*@ysize-25, ZOrder::Enemies) if @defense == 1000
    end
    
    def custom_mechanics
        @projectile = (@shield_counter == 0) && ((@hp <= @maxhp/2) || Difficulty.get > Difficulty::HARD)
        @shield_counter -= 1 if @shield_counter > 0
        @border_jump_delay = (@hunt_delay < @hunt_max_delay ? nil : 5)
        if @hp <= @maxhp*1.0 then
            if rand(300 + @troop_value*200 + (@hp/@maxhp*50).to_i - Difficulty.get*50) == 0 then
                en = @window.spawn_enemy(Enemies::Parashi, @x, @y - 425, [:left, :right].sample)
                en.extend_range
                @troops.push(en)
            end
        end
        if @hp <= @maxhp*0.75 then
            if rand(550 + @troop_value*200 + (@hp/@maxhp*100).to_i - Difficulty.get*50) == 0 then
                en = @window.spawn_enemy(Enemies::Raishi, @x, @y - 425, [:left, :right].sample)
                en.extend_range
                @troops.push(en)
            end
        end
        if @hp <= @maxhp*0.5 then
            if rand(1150 + @troop_value*200 + (@hp/@maxhp*100).to_i - Difficulty.get*50) == 0 then
                en = @window.spawn_enemy(Enemies::Hovershi, @x, @y - 425, [:left, :right].sample)
                en.extend_range
                @troops.push(en)
            end
        end
        if @hp <= @maxhp*0.25 then
            if rand(550 + @troop_value*200 + (@hp/@maxhp*100).to_i - Difficulty.get*50) == 0 then
                en = @window.spawn_enemy(Enemies::Shiteor, @x, @y - 425, [:left, :right].sample)
                en.extend_range
                @troops.push(en)
            end
        end
        if @hp <= @maxhp*0.5 then
            if rand(50) == 0 && @healing_counter > 0 && @shield_counter > 0 then
                val = @healing_counter*10
                @window.messages.push(["+ #{val}", @x, @y+@ysize, 100, true, 2.0, 2.0, 0xff8800ff])
                @hp += val
                @healing_counter -= 1
            end
        end
        if @hp <= @maxhp*0.25 && Difficulty.get > Difficulty::HARD then
            if rand(700 + @troop_value*100 + (@hp/@maxhp*100).to_i - Difficulty.get*50) == 0 then
                @speed = 2 + rand(6)
            end
        end
        if Difficulty.get > Difficulty::NORMAL && @hp <= @maxhp*0.3 then
            if rand(1000 + @troop_value*200 + (@hp/@maxhp*100).to_i - Difficulty.get*50) == 0 then
                en = @window.spawn_enemy(Enemies::Shi_52, @x, @y - 425, [:left, :right].sample)
                en.extend_range
                @troops.push(en)
            end
        end
        @troop_value = 0
        @random_jump_delay = 30 if @hp <= 2 && Difficulty.get > Difficulty::EASY
        @defense = 0  if @shield_counter == 0
        @speed = 4 if @shield_counter == 0 && @speed == 1
        @troops.each do |e|
            if !e.living then
                @troops.delete(e)
            end
            if (e.is_a? Raishi) || (e.is_a? Shiteor) then
                @defense = 1000
                @troop_value += 49
                @speed = 1
                @shield_counter = 100
            end
            if (e.is_a? Hovershi) then
                @troop_value += 9
            end
            @troop_value += 1
        end
    end
    
    def try_to_jump
        super()
        shoot_projectile if rand(3) == 0
    end
    
end
