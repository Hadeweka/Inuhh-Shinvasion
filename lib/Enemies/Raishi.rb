class Raishi < Enemy
    
    def activation
        @world = 3
        @speed = (SHIPEDIA ? 3 : 0)
        @gravity = false
        @abyss_turn = false
        @jump_image = false
        @havoc = true
        @air_control = true
        @crash_detonation = true
        @ysize = 50
        @defense = 1000
        @score = 0
        @world = 5
        @strength = 3
        @projectile_type = Projectiles::Fire
        @projectile_lifetime = 50
        @projectile_damage = (Difficulty.get > Difficulty::HARD ? 8 : 7)
        @projectile_owner = Projectiles::RAMPAGE
        load_graphic("Raishi")
        @description = "A Shinamite with a parachute. Will explode
        instantly by any contact and deal high damage.
        Rare inhibitant of the Shi Districts."
    end
    
    def move_mechanics
        @vy = 1
        @vx = (Math::cos(@tics/63.0*1000.0/500.0)*30.0/5.0)
        super
    end
    
    def at_collision
        fuse(1)
    end
    
    def damage(value)
        super(value)
        fuse(1)
    end
    
end
