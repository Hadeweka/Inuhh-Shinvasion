class Shilectron < Enemy
    
    def activation
        @strength = (Difficulty.get > Difficulty::NORMAL ? (Difficulty.get == Difficulty::DOOM ? 3 : 2) : 1)
        @gravity = false
        @hp = 3
        @strength = 3
        @reduction = 2
        @mindamage = 1
        @speed = 3
        @defense = 0
        @score = 8000
        @through = true
        @centrum = nil
        @init_centrum = [x, y]
        @radius = 100
        if @param then
            @radius = 50*@param
        end
        @world = 3
        @waterproof = true
        @va = (@dir == :right ? 1 : -1)*0.02*Math::PI
        @angle = 0
        @range = 100000
        @excited = false
        @excitation = 0
        @max_excitation = 250
        @radius_excitation_quotient = (Difficulty.get >= Difficulty::NORMAL ? (Difficulty.get == Difficulty::DOOM ? 0.6 : 0.4) : 0.2)
        @fluctuation = (Difficulty.get >= Difficulty::NORMAL ? (Difficulty.get == Difficulty::DOOM ? 0.1 : 0.05) : 0.025)
        @projectile = false
        @projectile_type = Projectiles::Spark 
        @projectile_lifetime = 400
        @projectile_damage = 3
        @no_harm_time = 0
        load_graphic("Shilectron")
        @description = "A Shi bound to a block or entity.
        It orbits around it in fixed circles.
        Found in Shi buildings and dark places."
    end
    
    def set_no_harm_time(value)
        @no_harm_time = value
        @dangerous = false
        @shading = 0x88ffffff
    end
    
    def bind(enemy, radius, angle, momentum, hp, strength)
        @centrum = enemy
        @radius = radius
        @angle = angle
        @va = momentum/@radius.to_f**2
        @hp = hp
        @strength = strength
        @score = 1000
    end
    
    def turn_to(dir)
        @va = (dir == :left ? -@va.abs : @va.abs)
    end

    def damage(value)
        super(value)
        if @excitation == 0 && @centrum.is_a?(Shitomium)
            @excited = true 
            @shading = 0xffffffff
            @no_harm_time = 0
            @projectile = true
        end
    end
    
    def update(cam_x, cam_y)
        @tics += 1
        if @excited && @excitation <= @max_excitation
            @excitation += 1
            @shading -= 0x00000101
            @shading = @shading.clamp(0xffff0000, 0xffffffff) 
        elsif @excitation > 0
            @excitation -= 4
            @shading += 0x00000404
            @shading = @shading.clamp(0xffff0000, 0xffffffff) 
        end
        @excitation = @excitation.clamp(0, @max_excitation)
        @invul -= 1 if @invul > 0
        @inuhh = @window.inuhh
        return nil unless check_range(cam_x, cam_y)
        if @centrum then
            @x = @centrum.x + (@radius + @excitation * @radius_excitation_quotient + @fluctuation * (rand - 0.5) * @excitation)*Math::cos(@angle)
            @y = @centrum.y + @ysize - @centrum.ysize + (@radius + @excitation * @radius_excitation_quotient + @fluctuation * (rand - 0.5) * @excitation)*Math::sin(@angle)
            @angle += @va
            @cur_image = @standing
        else
            @x = @init_centrum[0] + @radius*Math::cos(@angle)
            @y = @init_centrum[1] + @radius*Math::sin(@angle)
            @angle += @va
            @cur_image = @standing
        end  
        @damage_counter -= 1
        if @no_harm_time > 0 then
            @no_harm_time -= 1
        else
            @dangerous = true
            @shading = 0xffffffff unless @excitation != 0
        end
        if @excited && @excitation == @max_excitation
            @excited = false
            @window.spawn_projectile(@projectile_type, @x.to_f-Projectiles::XSizes[@projectile_type],
                                 @y.to_f-@ysize.to_f-Projectiles::YSizes[@projectile_type],
                                 (rand - 0.5) * 3, (rand - 0.5) * 3,
                                 *@projectile_mechanics[2..3],
                                 @projectile_owner, @projectile_lifetime, @projectile_damage)
        end
    end
    
end
