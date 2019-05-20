class Shirpedo < Enemy
    
    def activation
        @score = 16000
        @speed = 3
        @hp = 4
        @defense = 3
        @gravity = false
        @waterproof = true
        @dodge_range = 0.5
        @hunting = true
        @abyss_turn = false
        @border_turn = false
        @world = 6
        @anim_delay = 30
        @strength = 6
        @jump_image = false
        @projectile = true
        @projectile_type = Projectiles::Homing
        @projectile_reload = (Difficulty.get > Difficulty::NORMAL ? 91 : 133)
        @projectile_damage = (Difficulty.get > Difficulty::EASY ? 6 : 5)
        @projectile_offset = [0.0, -@ysize+3.0]
        @projectile_mechanics = [1.0, 0.0, 0.1, 0.1]
        load_graphic("Shirpedo")
        @description = "Dangerous diving Shi with a cannon.
        Shoots homing missiles, which are difficult to dodge.
        Can lead to long underwater dodging sessions.
        Found on Horror Island."
    end
    
    def move_mechanics
        super
        @vy = 0
        @vy = 1 if @inuhh.y > @y
        @vy = -1 if @inuhh.y < @y && @window.map.water(@x, @y - @ysize - 1)
    end
    
end
