class Shindelier < Enemy
    
    def activation
        @strength = (Difficulty.get == Difficulty::DOOM ? 12 : 11)
        @spike_strength = (Difficulty.get == Difficulty::DOOM ? 12 : 11)
        @mindamage = 3
        @minsdamage = 3
        @spike = true
        @score = 0
        @hp = 7
        @defense = 5
        @world = 6
        @angle = 0.0
        @a_speed = 0.05
        @va = 2.0*(@dir == :left ? -1 : 1)
        @va *= 4.0 if @param == 1
        @speed = 0
        @x_0 = @x
        @y_0 = @y
        @range = 10000
        @projectile_lifetime = 20
        @projectile_damage = 4
        @detonation_intensity = 10
        @projectile_type = Projectiles::Fire
        @detonation_speed = 1.0
        @gravity_detonation = -0.1
        @asignum = 1.0
        @speed = 2 if SHIPEDIA
        @through = true if SHIPEDIA
        @gravity = false
        @abyss_turn = false
        @ysize = 100 if SHIPEDIA
        load_graphic("Shindelier", @xsize, (SHIPEDIA ? @ysize : 4*@ysize))
        @description = "T"
    end
    
    def draw
        return if @invisible && !EDITOR
        # Flip vertically when facing to the left.
        if @dir == :left then
            offs_x = -@xsize
            factor = 1.0
        else
            offs_x = @xsize
            factor = -1.0
        end
        if !EDITOR then
            @cur_image.draw_rot(@x - 3*@xsize*Math::sin(@angle/180.0*Math::PI), @y - 3*@ysize*Math::cos(@angle/180.0*Math::PI) - @ysize, ZOrder::Enemies, -@angle)
        else
            @cur_image.draw(@x + offs_x, @y - @ysize*2 + 1 - 150, ZOrder::Enemies, factor, 1.0)
        end
    end
    
    def custom_mechanics
        if @centrum then
            @x_0 = @centrum.x
            @y_0 = @centrum.y + 8*@ysize
            @dir = @centrum.dir
            if @param == 1 then
                @va = 2.0*(@dir == :left ? -1 : 1)
                @va *= 4.0
            end
        end
        if @param == 1 then
            @angle += @va*@asignum
        else
            @va -= @a_speed*@a_speed*@angle
            @angle += @va*@asignum
        end
        if false
            
        else
            @x = @x_0 + 8*@xsize*Math::sin(@angle/180.0*Math::PI)
            @y = @y_0 + 8*@ysize*Math::cos(@angle/180.0*Math::PI) - 200
        end
        grav = (@gravity_detonation ? @gravity_detonation : 0.0)
        acc = @detonation_acc
        det_speed = @detonation_speed
        1.times do
            theta = 2.0*Math::PI * (rand)
            @window.spawn_projectile(@projectile_type, @x.to_f+(Projectiles::XSizes[@projectile_type]+@xsize*Math::cos(theta)),
                                     @y.to_f-@ysize.to_f-Projectiles::YSizes[@projectile_type]+@ysize*Math::sin(theta),
                                     det_speed*Math::cos(theta), det_speed*Math::sin(theta),
                                     acc*Math::cos(theta), grav+acc*Math::sin(theta), @projectile_owner, @projectile_lifetime, @projectile_damage, true)
        end
    end
    
    def bind(enemy)
        @centrum = enemy
    end
    
end
