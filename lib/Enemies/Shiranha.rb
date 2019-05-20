class Shiranha < Enemy
    
    def activation
        @hp = 4
        @strength = 4
        @defense = 3
        @score = 12000
        @world = 6
        @speed = 0
        @range = 200
        @waterproof = true
        @moving = false
        @spike = true
        @spike_strength = (Difficulty.get > Difficulty::NORMAL ? 8 : 6)
        @minsdamage = 2
        @dir_set = true
        @no_knockback = true
        @just_jumped = false
        @invisible = true
        @jump_image = false
        load_graphic("Shiranha")
        @speed = 3 if SHIPEDIA
        @description = "T"
    end
    
    def custom_mechanics
        @cur_image = ((milliseconds / @anim_delay).floor % 2 == 0) ? @walk1 : @walk2 if @damage_counter <= 0
        if !would_fit(0, 1) && !(@map.water(@x, @y, true)) then
            @vx = 0
            @just_jumped = false
            @moving = false
        end
        if !@just_jumped && (@inuhh.x - @x).abs < 15 && (1..300) === (@y - @inuhh.y) && !@moving then
            @vy = (@map.water(@x, @y, true) ? -25 : -15)
            @vx = 3*(@inuhh.x < @x ? 1 : -1)
            @just_jumped = true
            @moving = true
            @invisible = false
            @no_knockback = false
        end
        if @just_jumped && @map.water(@x, @y, true) && @vy > 0 then
            @just_jumped = false
            @moving = false
            @no_knockback = true
        end
    end
    
end
