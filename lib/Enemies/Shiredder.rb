class Shiredder < Enemy
    
    def activation
        @spike_strength = (Difficulty.get > Difficulty::EASY ? 5 : 4)
        @strength = (Difficulty.get > Difficulty::EASY ? 5 : 4)
        @minsdamage = 2
        @mindamage = 2
        @hp = 3
        @score = 10000
        @score = 0
        @speed = 2
        @havoc = true
        @world = 4
        @defense = 2
        @spike = true
        load_graphic("Shiredder")
        @description = "Strong Shihog variant with crimson color.
        Very hard to kill, so extremely dangerous.
        Found on many places near Shi institutions."
    end
    
end
