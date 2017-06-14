class Shihog < Enemy
    
    def activation
        @spike_strength = 2
        @strength = 2
        @minsdamage = 1
        @mindamage = 1
        @havoc = true
        @score = 4000
        @speed = 1
        @world = 1
        @spike = true
        @random_jump_delay = 1000 if Difficulty.get > Difficulty::HARD
        load_graphic("Shihog")
        @description = "Spikey Shi. Faster (but weaker) than the Shipikes.
        Found on many locations."
    end
    
end
