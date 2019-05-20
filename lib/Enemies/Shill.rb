class Shill < Enemy
    
    def activation
        @speed = 1
        @hp = 10
        @enemy_plus_damage = 6
        @jump_speed = -10
        @strength = 0
        @reduction = 1
        @dangerous = false
        @havoc = true
        @random_jump_delay = 30
        @score = 0
        @world = 6
        load_graphic("Shill")
        @description = "T"
    end
    
    def at_collision
        @knockback_vx = (@inuhh.x < @x ? 10 : -10)
    end
    
end
