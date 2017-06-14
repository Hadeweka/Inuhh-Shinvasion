class Shipike < Enemy # Dangerous Shi with a spike on their head
    
    def activation
        @spike_strength = 5
        @score = 3000
        @speed = 1
        @spike = true
        @ysize = 50
        @world = 1
        @minsdamage = 2
        @random_jump_delay = 10000 if Difficulty.get > Difficulty::HARD
        load_graphic("Shipike")
        @description = "Shi with spike helmet. Jumps on his head yield high damage,
        so avoiding it at any price is recommended.
        Very rare, but prefers caves and holes."
    end
    
end
