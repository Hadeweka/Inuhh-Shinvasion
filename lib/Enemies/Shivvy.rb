class Shivvy < Enemy
    
    def activation
        @score = 12000
        @hp = 8
        @jump_speed = -25
        @defense = 0
        @world = 4
        @strength = 6
        @speed = 1
        @random_jump = true
        @random_jump_delay = (Difficulty.get > Difficulty::HARD ? 400 : 500)
        load_graphic("Shivvy")
        @description = "This Shi does the dirty deeds. Can jump
        around sometimes because of its frustration.
        Works in sewers."
    end
    
end
