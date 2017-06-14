class Shilevator < Enemy
    
    def activation
        @score = 5000
        @range = 100000
        @strength = (Difficulty.get > Difficulty::HARD ? 3 : 2)
        @hp = 1
        @speed = 0
        @world = 3
        @defense = 1
        @riding = true
        @gravity = false
        @prepared = (@param == 1 ? 1 : -1)
        @moving = false
        @jump_image = false
        load_graphic("Shilevator")
        @description = "Useful Shi form. If someone's standing on
        its hat it will go straight up. Will also
        fall down if the passenger went too far
        down again, so it can be reused infinitely.
        Found in many Shi institutions."
    end
    
    def custom_mechanics
        if self == @inuhh.riding_entity then
            @vy = @prepared if @vy == 0 || @vy == 5
        elsif @vy != 0 && (@inuhh.y - @y) > 400 then
            @vy = 5
        end
        if @vy != 0 then
            if !would_fit(0, -1) then
                @vy = 1
            elsif !would_fit(0, 1) then
                @vy = -1
            end
        end
    end
    
end
