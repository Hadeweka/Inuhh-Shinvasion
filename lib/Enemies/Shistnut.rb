class Shistnut < Enemy
    
    def activation
        @speed = 0
        @hp = 3
        @defense = 4
        @score = 14000
        @world = 6
        @range = 200
        @spike = true
        @moving = false
        @gravity = false
        @dir_set = true
        @no_knockback = true
        @strength = (Difficulty.get > Difficulty::NORMAL ? 7 : 6)
        @spike_strength = (Difficulty.get > Difficulty::NORMAL ? 7 : 6)
        load_graphic("Shistnut")
        @projectile_damage = (Difficulty.get > Difficulty::HARD ? 5 : 4)
        @projectile_owner = Projectiles::RAMPAGE
        @speed = 1 if SHIPEDIA
        @gravity = true if SHIPEDIA
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
    
end
