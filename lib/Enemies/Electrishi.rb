class Electrishi < Enemy
    
    def activation
        @score = 21000
        @world = 6
        @strength = 10
        @spike_strength = 10
        @spike = true
        @gravity = false
        @abyss_turn = false
        @jump_image = false
        @air_control = true
        @defense = 3
        @speed = 2
        @hp = 9
        @havoc = true
        @projectile = true
        @projectile_reload = (Difficulty.get > Difficulty::EASY ? 250 : 300)
        @projectile_lifetime = 20
        @projectile_damage = 6
        @projectile_type = Projectiles::Spark
        @detonation_speed = 3.0
        @gravity_detonation = 0.0
        @projectile_offset = [0.0, 0.0]
        load_graphic("Electrishi")
        @description = "T"
    end
    
    def custom_mechanics
        grav = (@gravity_detonation ? @gravity_detonation : 0.0)
        acc = @detonation_acc
        det_speed = @detonation_speed
        rand(2).times do
            theta = 2.0*Math::PI * (rand)
            @window.spawn_projectile(@projectile_type, @x.to_f+(Projectiles::XSizes[@projectile_type]+@xsize*Math::cos(theta)),
                                     @y.to_f-@ysize.to_f-Projectiles::YSizes[@projectile_type]+@ysize*Math::sin(theta),
                                     det_speed*Math::cos(theta), det_speed*Math::sin(theta),
                                     acc*Math::cos(theta), grav+acc*Math::sin(theta), @projectile_owner, @projectile_lifetime, @projectile_damage, true)
        end
    end
    
    def shoot_projectile
        @speed = 0
        @projectile_lifetime = 500
        restore_vy = @vy
        @vy = 0
        dvecx = @inuhh.x - (@x + (@dir == :left ? -@xsize : @xsize))
        dvecy = @inuhh.y - (@y - 2*@ysize + 3.0)
        cosphi = ((@dir == :left ? -1.0 : 1.0)*dvecx / Math::sqrt(dvecx*dvecx + dvecy*dvecy))
        projx = cosphi*30.0
        projy = (@inuhh.y < @y ? -1.0 : 1.0)*Math::sqrt(1-cosphi*cosphi)*(25.0+rand(10)*1.0)
        @projectile_mechanics = [projx, projy, 0.0, 0.0]
        super()
        @vy = restore_vy
        @speed = 2
        @projectile_lifetime = 20
    end
    
end
