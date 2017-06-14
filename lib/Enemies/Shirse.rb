class Shirse < Enemy
    
    def activation
        @hp = (Difficulty.get > Difficulty::HARD ? 1 : 2)
        @defense = 0
        @strength = 2
        @speed = 3
        @score = 5000
        @jump_speed = -20
        @world = 3
        @riding = true
        load_graphic("Shirse")
        @description = "Unique Shi as it can be ridden. But it
        doesn't really like it and will speed up
        extremely if done so.
        Lives at the Westton Mountain."
    end
    
    def custom_mechanics
        if @inuhh.riding_entity != self then
            @abyss_turn = true
            @border_turn = true
            @speed = 3
        else
            @abyss_turn = false
            @border_turn = false
            if @window.button_down?(KbLeft) then
                @dir = :left
            end
            if @window.button_down?(KbRight) then
                @dir = :right
            end
            if @window.button_down?(KbSpace) then
                try_to_jump
            end
            if @window.button_down?(KbLeftControl) || @window.button_down?(KbRightControl) || @window.button_down?(KbLeftShift) || @window.button_down?(KbRightShift)then
                @speed = 10
            else
                @speed = 7
            end
        end
    end

end
