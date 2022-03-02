class Turboshi < Enemy
    
    def activation
        @score = 5000
        @range = 100000
        @strength = (Difficulty.get > Difficulty::HARD ? 3 : 2)
        @hp = 1
        @speed = 0
        @world = 4
        @defense = 1
        @riding = true
        @gravity = false
        @moving = false
        @jump_image = false
        load_graphic("Turboshi")
        @description = "Useful Shilevator with four-directional
        control. Still a little bit hard to use, because
        it was not built for dogs.
        Used in many Shi facilities."
    end
    
    def custom_mechanics
        if @inuhh.riding_entity == self then
            if Keys::is_down?(self, Keys::Run) then
                @vy -= 1
                @vy = -10 if @vy < -10
            else
                @vy += 1
                @vy = 10 if @vy > 10
            end
            if Keys::is_down?(self, Keys::Right) then
                @dir = :right
                @speed = 2
                @moving = true
            elsif Keys::is_down?(self, Keys::Left) then
                @dir = :left
                @speed = 2
                @moving = true
            else
                @speed = 0
                @moving = false
            end
        else
            @vy = 3
            @speed = 0
            @moving = false
        end
    end
    
end
