class TNShi < Enemy
    
    def activation
        @speed = 1
        @defense = 1000
        @score = 0
        @world = 2
        @projectile_damage = (Difficulty.get > Difficulty::HARD ? 4 : 3)
        @projectile_owner = Projectiles::RAMPAGE
        load_graphic("TNShi")
        @description = "Strange Shi with explosive content.
        Any touch will trigger a massive explosion.
        It can only be destroyed by this way.
        Lives in dark places."
    end
    
    def damage(value)
        super(value)
        @speed = 3
        fuse
    end
    
    def fuse_mechanics
        @range = 10000
        @shading -= 0x00000101 if @fuse_counter
        try_to_jump if @fuse_counter == 10
        super()
    end
    
    def at_collision
        @speed = 3
        fuse
    end
    
end
