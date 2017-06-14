class Mayshi < Enemy
    
    def activation
        @world = 3
        @hp = 4
        @strength = 4
        @defense = 1
        @jump_speed = -30
        @random_jump_delay = (Difficulty.get > Difficulty::HARD ? 50 : 100)
        @score = 9000
        @range = 400
        @random_jump = true
        load_graphic("Mayshi")
        @description = "Per se a harmless Shi, but it can jump
        very high and unpredictable.
        Lives near deserts."
    end
    
end
