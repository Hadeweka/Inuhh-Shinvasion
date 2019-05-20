class Shillowisp < Enemy
    
    def activation
        @score = 0
        @speed = 3
        @defense = 1000
        @world = 6
        @strength = 7
        @mindamage = (Difficulty.get > Difficulty::HARD ? 4 : 3)
        @minsdamage = @mindamage
        @through = true
        @spike = true
        @spike_strength = 7
        @gravity = false
        @hunting = true
        @waterproof = true
        @border_turn = false
        @abyss_turn = false
        @jump_image = false
        @air_control = true
        @projectile_lifetime = 50
        @projectile_damage = 4
        @detonation_intensity = 10
        @projectile_type = Projectiles::Fire
        @detonation_speed = 1.0
        @gravity_detonation = -0.2
        load_graphic("Shillowisp")
        @description = "T"
    end
    
    def move_mechanics
        super
        @vy = @speed if @inuhh.y > @y
        @vy = 0 if @inuhh.y == @y
        @vy = -@speed if @inuhh.y < @y
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
