class Daishi < Enemy
    # Same as Chishi, but much stronger... but also not the brightest
    
    def activation
        @strength = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
        @score = 3000
        @speed = (Difficulty.get == Difficulty::DOOM ? 2 : 1)
        @abyss_turn = false
        load_graphic("Daishi")
        @description = "Stronger variant of the Chishi, but not as intelligent. Doesn't mind abysses.
        Less common than the Chishi, but still not very rare."
    end
    
end
