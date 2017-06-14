class Shireball < Enemy
    
    def activation
        @score = 11000
        @moving = false
        @gravity = false
        @dir_set = true
        @strength = (Difficulty.get > Difficulty::EASY ? 5 : 4)
        @abyss_turn = false
        @world = 4
        @defense = 1
        @spike = true
        @havoc = true
        @spike_strength = (Difficulty.get > Difficulty::EASY ? 5 : 4)
        @range = 300
        @waterproof = true
        @speed = 10 if SHIPEDIA
        load_graphic("Shireball")
        @description = "A Shi hiding in lava flows. Shoots out in a
        straight line if detecting enemies.
        Lives in places with lava flows, what else."
    end
    
    def custom_mechanics
        if (@inuhh.y - @y).abs < 10 && (1..300) === (@inuhh.x - @x)*(@dir == :left ? -1 : 1)  && !@moving then
            @speed = 10
            @moving = true
        end
    end
    
end
