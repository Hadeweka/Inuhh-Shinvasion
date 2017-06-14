class Elashi < Enemy
    
    def activation
        @hp = 10
        @strength = (Difficulty.get > Difficulty::EASY ? 2 : 1)
        @jump_speed = -20
        @reduction = 1
        @score = 9000
        @world = 2
        @ysize = 50
        @abyss_turn = false
        @air_control = true
        load_graphic("Elashi")
        @description = "Elastic Shi with good jumping properties.
        Its elastic properties grant him the ability to
        take a fixed amount of hits independent of the damage.
        Not as common as a Chishi, but still quite common."
    end
    
    def custom_mechanics
        try_to_jump
    end
    
end
