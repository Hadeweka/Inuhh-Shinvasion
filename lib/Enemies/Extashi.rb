class Extashi < Enemy
    
    def activation
        @speed = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
        @score = 3000
        @world = 4
        @criminal = true
        diff_hash = {Difficulty::EASY => nil, Difficulty::NORMAL => 1000, Difficulty::HARD => 200, Difficulty::DOOM => 50}
        @random_jump_delay = diff_hash[Difficulty.get]
        @border_jump_delay = (Difficulty.get > Difficulty::EASY ? 10 : nil)
        @abyss_jump_delay = (Difficulty.get > Difficulty::EASY ? 10 : nil)
        load_graphic("Extashi")
        @description = "This Shi inhaled a little bit too much
        of some toxic vapours. Contact with it
        will lead to dizzyness and nausea.
        Lives next to Chishis on acid seas."
    end
    
    def at_collision
        @inuhh.make_drunk(1000)
    end
    
    def at_jumped_on
        @inuhh.make_drunk(1000)
    end
    
end
