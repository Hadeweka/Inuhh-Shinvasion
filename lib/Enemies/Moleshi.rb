class Moleshi < Enemy
    
    def activation
        @speed = 0
        @hp = 2
        @strength = (Difficulty.get > Difficulty::HARD ? 3 : 2)
        @defense = 0
        @world = 2
        @score = 5000
        @range = 200
        @invisible = true
        @moving = false
        @gravity = false
        @dir_set = true
        load_graphic("Moleshi")
        @description = "Hidden mole-like Shi jumping out of earth if disturbed.
        Loves to be in areas full of earth and caves."
        @speed = 2 if SHIPEDIA
        @gravity = true if SHIPEDIA
    end
    
    def custom_mechanics
        if (@inuhh.x - @x).abs < 50 && (0..100) === -(@inuhh.y - @y) && @invisible then
            @invisible = false
            @speed = 2
            @vy = -15
            @moving = true
            @gravity = true
        end
    end
    
end
