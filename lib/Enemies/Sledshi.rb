class Sledshi < Enemy
    
    def activation
        @speed = 0
        @hp = 10
        @defense = 5
        @score = 23000
        @world = 6
        @range = 300
        @xsize = 100
        @ysize = 100
        @spike = true
        @spike_strength = (Difficulty.get > Difficulty::HARD ? 20 : 10)
        @mindamage = 5
        @minsdamage = 5
        @moving = false
        @gravity = false
        @dir_set = true
        @jump_image = false
        @speed = 3 if SHIPEDIA
        @strength = (Difficulty.get > Difficulty::HARD ? 20 : 10)
        load_graphic("Sledshi")
        @gravity = true if SHIPEDIA
        @description = "T"
        @ground_hit = false
        @ready = true
    end
    
    def custom_mechanics
        if @ready && (@inuhh.x - @x).abs < 100 && (1..300) === (@inuhh.y - @y)  && !@moving then
            @gravity = true
            @ready = false
        end
        if !would_fit(0, 1) then
            @ground_hit = true
            @gravity = false
            @window.play_sound("detonation", 2, 0.5)
            @inuhh.try_to_jump
        end
        @vy = -3 if @ground_hit
        if !would_fit(0, -1) && @ground_hit then
            @ground_hit = false
            @ready = true
            @window.play_sound("detonation", 1, 0.3)
        end
    end
    
end
