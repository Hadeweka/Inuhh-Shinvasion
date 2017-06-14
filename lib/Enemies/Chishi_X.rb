class Chishi_X < Enemy
    
    def activation
        @strength = 3
        @defense = 1
        @hp = 3
        @world = 2
        @speed = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
        @score = 6000
        @random_jump_delay = 250 if Difficulty.get > Difficulty::HARD		# In previous versions Chishi were too unpredictable
        @border_jump_delay = 40 if Difficulty.get > Difficulty::HARD
        load_graphic("Chishi_X")
        @description = "Stronger Chishi variant with higher strength, health
        and defense, possible through genetic modifications.
        Found in dark places or occupied cities."
    end
    
end
