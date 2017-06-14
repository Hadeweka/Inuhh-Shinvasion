class Boxhi < Enemy
    
    def activation
        @speed = 0
        @world = 3
        @score = 4000
        @no_knockback = true
        @moving = false
        @dir_set = true
        @destiny = true
        @gravity = false
        @knockback = 10
        load_graphic("Boxhi")
        @description = "Exotic Shi with square-shape. It is impossible
        to break through it without removing it first.
        Also deals high knockback.
        Seems to be made of some sort of rubber.
        Found wherever it can interfere."
    end
    
end
