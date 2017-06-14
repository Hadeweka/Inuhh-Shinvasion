class Daishi_Y < Enemy
    
    def activation
        @strength = (Difficulty.get == Difficulty::DOOM ? 9 : 8)
        @score = 15000
        @defense = 3
        @world = 4
        @hp = 7
        @speed = (Difficulty.get == Difficulty::DOOM ? 2 : 1)
        @abyss_turn = false
        load_graphic("Daishi_Y")
        @description = "One of the strongest Shi of the entire empire.
        Can kill animals with one single hit!
        Found near to and inside of Shi headquarters."
    end
    
end
