class Shibmarine < Enemy # Underwater Shi, floating. Only useful in water, else paradox ;)
    
    def activation
        @score = 2000
        @speed = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
        @gravity = false
        @waterproof = true
        @abyss_turn = false
        @world = 1
        load_graphic("Shibmarine")
        @description = "Diving Shi for discovering water landscapes. Not
        stronger than a standard Chishi.
        Found everywhere with water."
    end
    
    def move_mechanics
        super
        if rand(100)==0 && Difficulty.get > Difficulty::HARD then
            @speed += rand(2)*2-1
            @speed = [[@speed, 1].max, 5].min
        end
    end
    
end
