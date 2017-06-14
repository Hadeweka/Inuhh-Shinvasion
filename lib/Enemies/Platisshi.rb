class Platisshi < Enemy
    
    def activation
        @hp = (Difficulty.get == Difficulty::EASY ? 2 : 1)
        @defense = 0
        @strength = 3
        @speed = 2
        @score = 5000
        @world = 2
        @xsize = 100
        @gravity = false
        @air_control = true
        @y += @ysize if !EDITOR && !SHIPEDIA
        @waterproof = true
        @abyss_turn = false
        @jump_image = false
        @riding = true
        load_graphic("Platisshi")
        @description = "Rideable variant of the Shilat. Very slow,
        but can glide over lava and deep abysses.
        Even more similar to a pancake than the Shilat.
        Its slightly crispy smell contributes to that.
        Dwells in lava caves and volcanos."
    end
    
end
