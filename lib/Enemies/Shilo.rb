class Shilo < Enemy # Really big Shi
    
    def activation
        @hp = 3
        @reduction = 1
        @score = 4000
        @xsize = 100
        @ysize = 100
        @range = 800
        @random_jump_delay = 200 if Difficulty.get > Difficulty::HARD
        @speed = (Difficulty.get > Difficulty::NORMAL ? 3 : 2)
        @world = 1
        load_graphic("Shilo")
        @description = "Very big Shi with no special abilities. Used from
        the Shi Empire to block important paths.
        Rarely found, and then only in wide areas."
    end
    
end
