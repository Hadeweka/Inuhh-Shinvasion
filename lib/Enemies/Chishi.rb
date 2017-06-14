class Chishi < Enemy
    
    def activation
        @speed = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
        @score = 2000
        @random_jump_delay = 500 if Difficulty.get > Difficulty::HARD		# In previous versions Chishi were too unpredictable
        @border_jump_delay = 50 if Difficulty.get > Difficulty::HARD
        @abyss_jump_delay = 50 if Difficulty.get > Difficulty::HARD
        @golden = (rand <= 1.0/77777.0)
        load_graphic("Chishi")
        if @golden then
            @score = 777000
            load_graphic("Chishi_Golden")
        end
        @description = "A common and normal member of the Shi Empire.
        Can be found nearly everywhere."
    end
    
    def at_death
        if @golden then
            @window.add_statistics(Statistics::Golden_Chishi, 1)
        end
    end
    
end
