class Enershi < Enemy # Charged and invincible floating Shi with highspeed
    
    def activation
        @score = 4000
        @speed = 10
        @spike = true
        @strength = (Difficulty.get > Difficulty::NORMAL ? 2 : 1)
        @spike_strength = (Difficulty.get > Difficulty::NORMAL ? 2 : 1)
        @abyss_turn = false
        @gravity = false
        @world = 2
        @havoc = true
        @mindamage = 1
        @minsdamage = 1
        @range = 100000 # Range of interaction outside of camera
        load_graphic("Enershi")
        @description = "High energy Shi with maximal speed. Cannot be defeated
        with jumps, so don't touch it.
        Very rare and can only be found next to technical institutions
        or high ranked Shi Empire members."
    end
    
end
