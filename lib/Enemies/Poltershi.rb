class Poltershi < Enemy
    
    def activation
        @speed = 3
        @strength = (Difficulty.get > Difficulty::EASY ? 4 : 3)
        @hp = 6
        @score = 9000
        @world = 4
        @random_jump_delay = (Difficulty.get > Difficulty::HARD ? 300 : 600)
        @border_jump_delay = 5
        @abyss_jump_delay = 5
        load_graphic("Poltershi")
        @description = "Nasty jumping Shi with high strength and health.
        One of the most unfair Shi species.
        Lives in dark and closed places, just to be unfair."
    end
    
end
