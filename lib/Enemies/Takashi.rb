class Takashi < Enemy
    
    def activation
        @speed = (Difficulty.get == Difficulty::DOOM ? 10 : 8)
        @score = 4000
        diff_hash = {Difficulty::EASY => nil, Difficulty::NORMAL => 1000, Difficulty::HARD => 200, Difficulty::DOOM => 50}
        @random_jump_delay = diff_hash[Difficulty.get]
        @border_jump_delay = 5
        @abyss_jump_delay = 5
        @world = 1
        load_graphic("Takashi")
        @description = "Insanely fast Shi. Can jump around erratically and
        unpredictable, but does only few damage.
        Can be found in many places, but is rather rare."
    end
    
end
