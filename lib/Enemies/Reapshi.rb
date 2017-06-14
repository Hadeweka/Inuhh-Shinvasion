class Reapshi < Enemy
    
    def activation
        @score = 0
        @speed = 1
        @defense = 1000
        @world = 4
        @strength = 666
        @mindamage = 666
        @minsdamage = 666
        @through = true
        @spike = true
        @spike_strength = 666
        @gravity = false
        @hunting = true
        @waterproof = true
        @border_turn = false
        @abyss_turn = false
        @jump_image = false
        @air_control = true
        load_graphic("Reapshi")
        @description = "Grim Shi which kills instantly by contact.
        Running away is the only option.
        Found only in really sinister areas."
    end
    
    def move_mechanics
        super
        @vy = @speed if @inuhh.y > @y
        @vy = 0 if @inuhh.y == @y
        @vy = -@speed if @inuhh.y < @y
    end
    
end
