class Shitake < Enemy
    
    def activation
        @speed = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
        @score = 4000
        @world = 2
        @hp = 5
        load_graphic("Shitake")
        @description = "Tough Shi member with many HP. Ideal for
        some jumping maneuvers.
        Lives in the Dominwood Forest and is very common."
    end
    
end
