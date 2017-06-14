class Daishi_X < Enemy
    
    def activation
        @strength = (Difficulty.get == Difficulty::DOOM ? 5 : 4)
        @score = 8000
        @defense = 1
        @world = 2
        @hp = 4
        @speed = (Difficulty.get == Difficulty::DOOM ? 2 : 1)
        @abyss_turn = false
        load_graphic("Daishi_X")
        @description = "Very strong mutant of the Daishi species.
        Found at places which are important for the Shi."
    end
    
end
