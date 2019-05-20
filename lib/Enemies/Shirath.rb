class Shirath < Enemy
    
    def activation
        @score = 0
        @speed = 5
        @defense = 3
        @spike = true
        @spike_strength = 3
        @hp = 13
        @world = 6
        @strength = 10
        @bulletproof = true
        @gravity = false
        @hunting = true
        @waterproof = true
        @border_turn = false
        @fusion = true
        @abyss_turn = false
        @jump_image = false
        @air_control = true
        load_graphic("Shirath")
        @description = "T"
    end
    
    def move_mechanics
        super
        @vy = @speed if @inuhh.y > @y
        @vy = 0 if @inuhh.y == @y
        @vy = -@speed if @inuhh.y < @y
    end
    
end
