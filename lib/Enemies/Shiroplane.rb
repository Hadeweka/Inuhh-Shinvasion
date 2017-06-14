class Shiroplane < Enemy # Chishi with better jump abilities, can also jump mid-air
    
    def activation
        @score = 3000
        @speed = (Difficulty.get > Difficulty::HARD ? 2 : 1)
        @range = 300
        @world = 1
        @random_jump_delay = 10
        @air_control = true
        load_graphic("Shiroplane")
        @description = "Special Shi unit with jetpack. Not very skilled at this, though,
        therefore sometimes falling down without warning.
        Usually hiding in clouds it appears on ground rarely."
    end
    
    def try_to_jump
        @vy = -10
        @jumping = true
    end
    
end
