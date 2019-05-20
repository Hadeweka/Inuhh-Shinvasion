class Shippuku < Enemy
    
    def activation
        @strength = 7
        @hp = 13
        @defense = 4
        @world = 6
        @speed = 1
        @score = 20000
        @projectile = true
        @projectile_reload = (Difficulty.get > Difficulty::EASY ? 60 : 70)
        @projectile_damage = 7
        @projectile_type = Projectiles::Fire
        @projectile_offset = [0.0, -@ysize+3.0]
        @projectile_mechanics = [1.0+4.0*rand, rand-0.5, 0.0, 0.0]
        @detonation_speed = 10.0
        @gravity_detonation = 0.5
        load_graphic("Shippuku")
        @description = "T"
    end
    
    def custom_mechanics
        @projectile_mechanics = [1.0+4.0*rand, rand-0.5, 0.0, 0.0]
    end
    
    def at_death
        @projectile_lifetime = 30
        @projectile_owner = Projectiles::RAMPAGE
        detonate
    end
    
end
