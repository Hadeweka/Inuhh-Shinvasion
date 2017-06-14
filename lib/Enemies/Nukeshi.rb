class Nukeshi < Enemy
    
    def activation
        @hp = 5
        @strength = 2
        @score = 7000
        @speed = (Difficulty.get > Difficulty::HARD ? 2 : 1)
        @defense = 0
        @world = 2
        @fuse_counter = nil
        @projectile_damage = 10
        @jump_speed = -30
        @projectile_type = Projectiles::Doom
        @projectile_owner = Projectiles::RAMPAGE
        @detonation_intensity = 50
        @detonation_speed = 5
        @detonation_acc = -0.1
        @gravity_detonation = 0.0
        load_graphic("Nukeshi")
        @description = "Rare Shi with no obvious properties.
        But if hit with a projectile, it unleashes its
        inner power and becomes very destructive to the
        extent of destroying the whole place.
        It lives in dark and unknown places."
    end
    
    def fuse_mechanics
        @range = 10000
        @shading -= 0x00000101 if @fuse_counter
        try_to_jump if @fuse_counter == 10
        super()
    end
    
    def at_shot(projectile)
        @defense = 1000
        fuse
        super(projectile)
    end
    
end
