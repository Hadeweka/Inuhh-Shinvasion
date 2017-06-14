class Shizooka < Enemy
    
    def activation
        @speed = 0
        @hp = 3
        @defense = 1000
        @strength = 1
        @score = 0
        @range = 1000
        @world = 1
        @moving = false
        @dir_set = true
        @projectile = true
        @projectile_reload = 153
        @projectile_damage = (Difficulty.get > Difficulty::EASY ? 3 : 2)
        @projectile_offset = [0.0, -@ysize+2.5]
        @projectile_mechanics = [5.0, 0.0, 0.0, 0.0]
        load_graphic("Shizooka")
        @description = "Upgraded version of a Shistol. Hides in dark corners
        and shoots continuously.
        Found on important places, sometimes even to guard high Shi."
    end
    
end
