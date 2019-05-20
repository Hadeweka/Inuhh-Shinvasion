class Cocoshi < Enemy
    
    def activation
        @speed = 0
        @hp = 6
        @defense = 7
        @score = 0
        @world = 6
        @range = 200
        @moving = false
        @gravity = false
        @dir_set = true
        @no_knockback = true
        @strength = 8
        @projectile_damage = 6
        @gravity_detonation = 1.0
        @detonation_speed = 15.0
        @projectile_owner = Projectiles::RAMPAGE
        @speed = 1 if SHIPEDIA
        @gravity = true if SHIPEDIA
        load_graphic("Cocoshi")
        @description = "T"
    end
    
    def custom_mechanics
        if (@inuhh.x - @x).abs < 50 && (1..300) === (@inuhh.y - @y)  && !@moving then
            @speed = 1
            @moving = true
            @no_knockback = false
            @gravity = true
            @crash_detonation = true
        end
    end
    
    def damage(value)
        super(value)
        @speed = 1
        @moving = true
        @no_knockback = false
        @gravity = true
        @crash_detonation = true
    end
    
end
