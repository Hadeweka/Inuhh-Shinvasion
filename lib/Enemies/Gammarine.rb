class Gammarine < Enemy # Hunting Shibmarine
    
    def activation
        @score = 4000
        @strength = (Difficulty.get > Difficulty::NORMAL ? 2 : 1)
        @speed = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
        @gravity = false
        @hunting = true
        @world = 1
        @waterproof = true
        @abyss_turn = false
        @jump_image = false
        load_graphic("Gammarine")
        @description = "Diving and hunting Shi member.
        Found in most lakes."
    end
    
    def move_mechanics
        super
        if rand(100)==0 && Difficulty.get > Difficulty::HARD then
            @speed += rand(2)*2-1
            @speed = [[@speed, 1].max, 5].min
        end
        @vy = 0
        @vy = @speed if @inuhh.y > @y
        @vy = -@speed if @inuhh.y < @y && @window.map.water(@x, @y - @ysize - 1)
        
    end
    
    def try_to_jump
        
    end
    
end
