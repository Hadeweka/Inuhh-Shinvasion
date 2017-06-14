class Shibmarine_Z < Enemy
    
    def activation
        @score = 8000
        @strength = 3
        @defense = 2
        @hp = 2
        @speed = 4
        @gravity = false
        @abyss_turn = false
        @world = 3
        @air_control = true
        @waterproof = true
        @range = 300
        load_graphic("Shibmarine_Z")
        @description = "Stronger and faster Shibmarine. Its high speed can
        be some great hazard if taken too lightly.
        Lives in some seas at the Westton Mountain."
    end
    
    def move_mechanics
        super
        if rand(150)==0 && Difficulty.get > Difficulty::HARD then
            @speed += rand(2)*2-1
            @speed = [[@speed, 3].max, 5].min
        end
    end
    
end
