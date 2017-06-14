class Shinegun < Enemy
    
    def activation
        @strength = 5
        @hp = 7
        @defense = 3
        @world = 5
        @speed = 1
        @score = 14000
        @projectile = true
        @drop = Objects::Shinegun if rand(10) == 0 || SHIPEDIA
        @random_jump_delay = (Difficulty.get > Difficulty::HARD ? 1000 : 2000)
        @projectile_reload = (Difficulty.get > Difficulty::NORMAL ? 61 : 73)
        @projectile_damage = 5
        @projectile_offset = [0.0, -@ysize+3.0]
        @projectile_mechanics = [5.0, 0.0, 0.0, 0.0]
        load_graphic("Shinegun")
        @description = "Strong Shistol upgrade. Jumps sometimes to
        hit higher targets. Also has some high defense.
        Lives in the Shi Districts."
    end
    
end
