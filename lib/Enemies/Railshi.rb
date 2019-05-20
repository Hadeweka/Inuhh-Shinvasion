class Railshi < Enemy
    
    def activation
        @hp = 1
        @defense = 0
        @strength = 7
        @speed = 10
        @range = 100000
        @score = 12000
        @world = 6
        @y -= @ysize if !SHIPEDIA && !EDITOR
        @gravity = false
        @air_control = true
        @waterproof = true
        @abyss_turn = false
        @jump_image = false
        @riding = true
        load_graphic("Railshi")
        @description = "Dangerous rideable Shi with high speed.
        At contact with walls it will turn around
        so quick that everyone riding it will be
        knocked away.
        Lives on Horror Island."
    end
    
    def border_mechanics
        if (!would_fit(1, 0) && @dir == :right) || (!would_fit(-1, 0) && @dir == :left) then
            @hunt_delay = @hunt_max_delay
            if @inuhh.riding_entity == self then
                @inuhh.try_to_jump
                @inuhh.knockback((@dir == :left ? -1 : 1)*40)
            end
            if !@border_jump_delay then
                switch_dir if @border_turn && @vy == 0
            elsif !random_jump(@border_jump_delay) then
                switch_dir if @border_turn && @vy == 0
            end
        end
    end
    
end
