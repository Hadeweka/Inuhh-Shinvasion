class Shirgantua < Enemy
    
    def activation
        @hp = 20
        @strength = 10
        @score = 22000
        @world = 6
        @speed = 1
        @hunting = true
        @xsize = 300
        @ysize = 300
        @through = true
        @drop_shift = -@ysize
        @range = 2000
        @abyss_turn = false
        @border_turn = false
        @drop = Objects::Key
        @waterproof = true
        @gravity = false
        @jump_image = false
        load_graphic("Shirgantua")
        @description = "This Shi is even bigger than the Koroshi!
        It will hunt and destroy every non-Shi it
        crosses, but it is still very slow. It can
        swim through walls, though. The collision
        detection would take too long otherwise.
        Lives on Port Pain."
    end
    
end
