class Shiteor < Enemy
    
    def activation
        @score = 15000
        @strength = 10
        @spike = true
        @spike_strength = 10
        @defense = 2
        @hp = 1
        @speed = 1
        @vy = 1
        @havoc = true
        @bulletproof = true
        @gravity = false
        @projectile_damage = 5
        @projectile_type = Projectiles::Fire
        @detonation_intensity = 100
        @projectile_owner = Projectiles::RAMPAGE
        @detonation_speed = 10
        @gravity_detonation = 0.2
        @abyss_turn = false
        @world = 3
        load_graphic("Shiteor")
        @description = "One of the most dangerous Shi. Steers right
        down to earth to explode in a great fireball.
        Also any jump will result in severe burns.
        Running away might be the best solution.
        Located on top of the Westton Mountain."
    end
    
    def border_mechanics
        if !would_fit(0, 1) || (!would_fit(1, 0) && @dir == :right) || (!would_fit(-1, 0) && @dir == :left) then
            detonate
        end
    end
    
end
