class Gasshi < Enemy # Fast and strong and can jump over some holes
    
    def activation
        @strength = 2
        @score = 5000
        @speed = 5
        @range = 300
        @world = 2
        @hunting = true
        @border_turn = false
        @abyss_turn = false
        @border_jump_delay = 1
        @abyss_jump_delay = 1
        @random_jump_delay = (Difficulty.get > Difficulty::NORMAL ? 100 : nil)
        load_graphic("Gasshi")
        @description = "Dangerous and fast Shi with decent hunting abilities.
        Will do anything to follow his victim, even high jumps.
        Hates water, cannot be found on the Cleanbuil Lake therefore."
    end
    
end
