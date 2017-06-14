class Shilopard < Enemy
    
    def activation
        @xsize = 75
        @ysize = 50
        @world = 5
        @hp = 20
        @hunting = true
        @defense = 2
        @projectile_damage = 5
        @projectile = true
        @projectile_reload = 3
        @projectile_lifetime = 10
        @projectile_offset = [-30.0, -20.0]
        @projectile_mechanics = [20.0, -4.0, 0.0, 1.0]
        @projectile_type = Projectiles::Fire
        @detonation_speed = 10.0
        @gravity_detonation = 0.2
        @border_turn = false
        @abyss_turn = false
        @havoc = true
        @strength = 10
        @score = 25000
        @speed = 1
        load_graphic("Shilopard")
        @description = "Heavy Shi tank with a flamethrower and decent hunting
        abilities. Also it has a good defense and will explode
        if destroyed.
        Found in the Shi Districts."
    end
        
    def custom_mechanics
        @projectile_mechanics[1] = -4.0 + (rand*8.0)-4.0
    end
        
    def at_death
        @projectile_lifetime = 20
        @projectile_owner = Projectiles::RAMPAGE
        detonate
    end
        
end
