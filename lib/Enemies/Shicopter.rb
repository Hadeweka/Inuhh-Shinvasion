class Shicopter < Enemy
    
    def activation
        @score = 6000
        @world = 3
        @hp = (Difficulty.get > Difficulty::HARD ? 3 : 2)
        @speed = 3
        @strength = 3
        @spike = true
        @spike_strength = 3
        @gravity = false
        @abyss_turn = false
        @jump_image = false
        @anim_delay = 17
        @air_control = true
        load_graphic("Shicopter")
        @description = "More stable version of the Shiroplane.
        Uses rotors to stay in air, so jumping on
        it will result in great pain.
        Can be found everywhere, even indoors."
    end
    
end
