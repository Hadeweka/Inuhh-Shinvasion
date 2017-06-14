class Shicicle < Enemy
    
    def activation
        @speed = 0
        @hp = 5
        @defense = 1
        @score = 10000
        @world = 4
        @range = 300
        @moving = false
        @gravity = false
        @dir_set = true
        @strength = (Difficulty.get > Difficulty::NORMAL ? 6 : 5)
        load_graphic("Shicicle")
        @description = "Similar to the Shipple, but much stronger.
        Falls down from ceilings if someone comes too close.
        Can be found in ice caves."
        @speed = 1 if SHIPEDIA
        @gravity = true if SHIPEDIA
    end
    
    def custom_mechanics
        if (@inuhh.x - @x).abs < 50 && (1..300) === (@inuhh.y - @y) && !@moving then
            @speed = 1
            @moving = true
            @gravity = true
        end
    end
    
end
