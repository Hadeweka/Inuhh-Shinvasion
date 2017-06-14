class Shipectral < Enemy
    
    def activation
        @score = 0
        @speed = 1
        @defense = 1000
        @world = 2
        @strength = 2
        @mindamage = (Difficulty.get > Difficulty::HARD ? 2 : 1)
        @minsdamage = @mindamage
        @through = true
        @spike = true
        @spike_strength = 2
        @gravity = false
        @hunting = true
        @waterproof = true
        @border_turn = false
        @abyss_turn = false
        @jump_image = false
        @air_control = true
        load_graphic("Shipectral")
        @description = "Mean ghost-like Shi flying through walls.
        Also invincible, so running away is the best thing to do.
        Cannot be defeated by simple jumps!
        It is usually found in dark areas or by night."
    end
    
    def move_mechanics
        super
        @vy = @speed if @inuhh.y > @y
        @vy = 0 if @inuhh.y == @y
        @vy = -@speed if @inuhh.y < @y
    end
    
end
