class Fisshi < Enemy
    
    def activation
        @score = 13000
        @world = 6
        @hp = 12
        @strength = 5
        @projectile_damage = 4
        @projectile_owner = Projectiles::RAMPAGE
        @bulletproof = true
        @projectile_lifetime = 20
        @gravity_detonation = 0.0
        @detonation_intensity = [20, (4 - @param)*20].max if @param
        @projectile_type = Projectiles::Spark
        @speed = [1, 4 - @param].max if @param
        @speed = 4 if !@param
        @xsize = 25*(@param + 1) if @param
        @ysize = 25*(@param + 1) if @param
        load_graphic("Fisshi", 25, 25)
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
        if EDITOR then
            @cur_image = @standing if !@moving && !@dir_set
            @cur_image.draw(@x + offs_x, @y - @ysize*2 + 1, ZOrder::Enemies, factor*(@xsize / 25), 1.0*(@ysize / 25), @shading)
        else
            distance = 200.0
            factor = 1.0 if !@moving && !@dir_set
            zxsize = @xsize*1.0/(1.0 + @z/distance)
            zysize = @ysize*1.0/(1.0 + @z/distance)
            zord = (@z < 0 ? ZOrder::Foreground : ZOrder::Enemies)
            @cur_image.draw(@x - factor*zxsize, @y - zysize*2 + 1 + zysize-@ysize, zord, factor*zxsize/@xsize*(@xsize / 25), zysize/@ysize*(@ysize / 25), @shading)
        end
    end
    
    def at_death
        return if @param == 0 || !@param
        detonate
        @window.spawn_enemy(Enemies::Fisshi, @x, @y, :left, @param - 1)
        @window.spawn_enemy(Enemies::Fisshi, @x, @y, :right, @param - 1)
    end
    
    def detonate
        return if @detonated
        @detonated = true
        grav = (@gravity_detonation ? @gravity_detonation : 0.0)
        max = @detonation_intensity
        acc = @detonation_acc
        det_speed = @detonation_speed
        0.upto(max-1) do |i|
            theta = (0.0-0.2/2)*Math::PI + 0.2*Math::PI * (2*i.to_f/max.to_f) if i < max/2
            theta = (1.0-0.2/2)*Math::PI + 0.2*Math::PI * (2*(i.to_f - max/2)/max.to_f) if i >= max/2
            @window.spawn_projectile(@projectile_type, @x.to_f+(Projectiles::XSizes[@projectile_type]+@xsize*Math::cos(theta)),
                                     @y.to_f-@ysize.to_f-Projectiles::YSizes[@projectile_type]+@ysize*Math::sin(theta),
                                     det_speed*Math::cos(theta), det_speed*Math::sin(theta),
                                     acc*Math::cos(theta), grav+acc*Math::sin(theta), @projectile_owner, @projectile_lifetime, @projectile_damage, true)
        end
        damage(1000)
        @window.play_sound("detonation", 1, 0.9+rand*0.2)
    end
    
end
