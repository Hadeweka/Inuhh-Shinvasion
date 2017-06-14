class Chishi_Y < Enemy
    
    def activation
        @strength = 5
        @defense = 3
        @hp = 10
        @world = 3
        @speed = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
        @score = 14000
        @random_jump_delay = 100 if Difficulty.get > Difficulty::HARD		# In previous versions Chishi were too unpredictable
        @border_jump_delay = 30 if Difficulty.get > Difficulty::HARD
        load_graphic("Chishi_Y")
        @description = "Strongest Chishi mutant and elite unit.
        Can only be found in important facilities."
    end
    
end
