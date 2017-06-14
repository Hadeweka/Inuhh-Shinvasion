class Shirman < Enemy
    
    def activation
        @xsize = 75
        @ysize = 50
        @world = 5
        @hp = 16
        @havoc = true
        @hunting = true
        @defense = 1
        @abyss_turn = false
        @border_turn = false
        @border_jump_delay = 10
        @abyss_jump_delay = 10
        @projectile_damage = 7
        @projectile = true
        @projectile_reload = 71
        @random_jump_delay = 200
        @jump_image = false
        @projectile_lifetime = 50
        @projectile_offset = [-30.0, -20.0]
        @projectile_mechanics = [20.0, -4.0, 0.0, 1.0]
        @projectile_type = Projectiles::Fire
        @detonation_speed = 10.0
        @gravity_detonation = 0.2
        @strength = 12
        @score = 23000
        @speed = 2
        load_graphic("Shirman")
        @description = "A Shi tank with a precise cannon. Not as
        heavy as the Shilopard, but stronger and faster.
        Will explode on destruction.
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
