class Shifeguard < Enemy
    
    def activation
        @speed = 0
        @hp = 12
        @defense = 2
        @score = 0
        @world = 6
        @moving = false
        @dir_set = true
        @waterproof = true
        @strength = 8
        @speed = 6 if SHIPEDIA
        load_graphic("Shifeguard")
        @description = "T"
    end
    
    def damage(value)
        super(value)
        return if @moving
        @speed = 6
        @jump_speed = -20
        @moving = true
        @no_knockback = false
        @border_turn = false
        @border_jump_delay = 10
        @abyss_jump_delay = 10
        @random_jump_delay = 75
        @abyss_turn = false
        @hunting = true
    end
    
    def custom_mechanics
        @dir_set = !@dir_set if rand < 0.01
        @dir_set = false if @moving
        @dir = [:right, :left].sample if !@moving && rand < 0.05
        if @knockback_vx != 0 && !@moving then
            @speed = 6
            @jump_speed = -20
            @moving = true
            @no_knockback = false
            @border_turn = false
            @border_jump_delay = 10
            @random_jump_delay = 75
            @abyss_jump_delay = 10
            @abyss_turn = false
            @hunting = true
        end
        if @window.shi_cry_heard && !@moving then
            @speed = 6
            @jump_speed = -20
            @moving = true
            @no_knockback = false
            @border_turn = false
            @border_jump_delay = 10
            @abyss_jump_delay = 10
            @random_jump_delay = 75
            @abyss_turn = false
            @hunting = true
            try_to_jump
        end
        @jump_image = !@map.water(@x, @y)
        if @moving && @map.water(@x, @y) then
            @vy += (@inuhh.y > @y ? rand(3) : -rand(3))
        end
    end
    
end
