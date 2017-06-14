class Shirror < Enemy
    
    def activation
        @score = 0
        @strength = 666
        @spike = true
        @spike_strength = 666
        @mindamage = 666
        @minsdamage = 666
        @defense = 1000
        @speed = 4
        @gravity = false
        @waterproof = true
        @abyss_turn = false
        @through = true
        @border_turn = false
        @jump_image = false
        @range = 100000
        @world = 4
        @destiny = true
        load_graphic("Shirror")
        @description = "Faster version of the Shireen.
        Run away as fast as possible... or die.
        Appears in sewers."
    end
    
    def custom_mechanics
        if @x+@xsize > @map.width*50 || @x-@xsize < 0 then
            @dir = (@dir == :left ? :right : :left)
        end
    end
    
end
