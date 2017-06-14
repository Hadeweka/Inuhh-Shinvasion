class Shireen < Enemy
    
    def activation
        @score = 0
        @strength = 666
        @spike = true
        @spike_strength = 666
        @defense = 1000
        @speed = 2
        @mindamage = 666
        @minsdamage = 666
        @gravity = false
        @waterproof = true
        @abyss_turn = false
        @through = true
        @border_turn = false
        @jump_image = false
        @range = 100000
        @world = 2
        @destiny = true
        load_graphic("Shireen")
        @description = "This Shi always comes up in masses.
        It travels only in one direction and cannot be stopped.
        Touching it is more than deadly.
        Appears in the deep Dominwood."
    end
    
    def custom_mechanics
        if @x+@xsize > @map.width*50 || @x-@xsize < 0 then
            @dir = (@dir == :left ? :right : :left)
        end
    end
    
end
