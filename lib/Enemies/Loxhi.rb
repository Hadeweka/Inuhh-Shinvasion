class Loxhi < Enemy
    
    def activation
        @speed = 0
        @world = 5
        @score = 0
        @strength = 3
        @no_knockback = true
        @mindamage = 1
        @defense = 1000
        @bulletproof = true
        @moving = false
        @dir_set = true
        @destiny = true
        @gravity = false
        @proj_hit = false
        @knockback = (Difficulty.get > Difficulty::NORMAL ? 15 : 10)
        @lock_colors = []
        @lock_colors[0] = 0x00ffffff
        @lock_colors[1] = 0x00ff0000
        @lock_colors[2] = 0x0000ff00
        @lock_colors[3] = 0x000000ff
        @lock_state = (@param ? @param : 0)
        if !EDITOR && !SHIPEDIA && !@window.triggers[Trigger_ID::Loxhi] then
            @window.triggers[Trigger_ID::Loxhi] = 0
        end
        load_graphic("Loxhi")
        @description = "Unusual Shi which makes all Loxhi of
        its color passable if hit. All other Loxhi
        will get solid, though.
        Placed in and near the Shi Factory."
    end
    
    def at_shot(projectile)
        @ball_hit = true if projectile.type == Projectiles::Ball
    end
    
    def damage(value)
        super(value)
        @window.triggers[Trigger_ID::Loxhi] = @lock_state if !@ball_hit
        @ball_hit = false
    end

    def draw
        if SHIPEDIA then
            
        elsif EDITOR then
            @shading = @lock_colors[@lock_state] + 0xff000000
        else
            @shading = @lock_colors[@lock_state] + ((@window.triggers[Trigger_ID::Loxhi] != @lock_state) ? 0xff000000 : 0x44000000)
        end
        super()
    end
    
    def custom_mechanics
        @transparent = !(@window.triggers[Trigger_ID::Loxhi] != @lock_state)
    end
    
end
