class Climbshi < Enemy
    
    def activation
        @score = 11000
        @strength = 3
        @hp = 12
        @world = 4
        @speed = 1
        @falling = false
        @jump_image = false
        @border_turn = false
        load_graphic("Climbshi")
        @description = "This Shi just wants to climb some hills
        and causes few trouble. Can be kicked
        down if jumped on. This is not very nice, though.
        Found on high cliffs."
    end
    
    def custom_mechanics
        @falling -= 1 if @falling
        @falling = false if @falling && @falling <= 0
    end
    
    def border_mechanics
        if (!would_fit(1, 0) && @dir == :right) || (!would_fit(-1, 0) && @dir == :left) then
            @vy = (Difficulty.get > Difficulty::HARD ? -3 : -2) if !@falling
        end
    end
    
    def damage(value)
        super(value)
        @falling = 20 if !would_fit((@dir == :left ? -1 : 1),0)
    end
    
end
