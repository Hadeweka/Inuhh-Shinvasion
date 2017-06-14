class Shignite < Enemy
    
    def activation
        @score = 7000
        @world = 3
        @strength = 2
        @spike_strength = (Difficulty.get > Difficulty::EASY ? 2 : 1)
        @spike = true
        @defense = 0
        @speed = 4
        @hp = 3
        @havoc = true
        @projectile_lifetime = 50
        @projectile_damage = 2
        @projectile_type = Projectiles::Fire
        @detonation_speed = 1.0
        @gravity_detonation = 0.01
        load_graphic("Shignite")
        @description = "Could be some normal Shi if it hadn't
        been ignited by someone. Therefore very fast.
        Spreads some particles because of the fire.
        Lives in fire caves and volcanos."
    end
    
    def custom_mechanics
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
    
end
