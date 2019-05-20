class Shiryumov < Enemy
    
    def activation
        @score = 196900
        @world = 6
        @strength = 6
        @spike_strength = (Difficulty.get > Difficulty::EASY ? 7 : 6)
        @spike = true
        @defense = 6
        @speed = 1
        @hp = 67
        @havoc = true
        @gravity = false
        @abyss_turn = false
        @jump_image = false
        @air_control = true
        @projectile_damage = 5
        @projectile_type = Projectiles::Fire
        @projectile_lifetime = 200
        @detonation_speed = 0.5
        @gravity_detonation = 0.0
        load_graphic("Shiryumov")
        @description = "T"
    end
    
    def custom_mechanics
        grav = (@gravity_detonation ? @gravity_detonation : 0.0)
        acc = @detonation_acc
        det_speed = @detonation_speed
        1.times do
            next if rand(5) != 0
            theta = 2.0*Math::PI * (rand)
            @window.spawn_projectile(@projectile_type, @x.to_f+(Projectiles::XSizes[@projectile_type]+@xsize*Math::cos(theta)),
                                     @y.to_f-@ysize.to_f-Projectiles::YSizes[@projectile_type]+@ysize*Math::sin(theta),
                                     det_speed*Math::cos(theta), det_speed*Math::sin(theta),
                                     acc*Math::cos(theta), grav+acc*Math::sin(theta), @projectile_owner, @projectile_lifetime, @projectile_damage, true)
        end
    end
    
end
