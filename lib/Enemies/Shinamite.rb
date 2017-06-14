class Shinamite < Enemy
    
    def activation
        @speed = 2
        @defense = 1000
        @score = 0
        @havoc = true
        @world = 5
        @strength = 3
        @projectile_type = Projectiles::Fire
        @projectile_damage = (Difficulty.get > Difficulty::HARD ? 8 : 7)
        @projectile_owner = Projectiles::RAMPAGE
        load_graphic("Shinamite")
        @description = "Overpowered TNShi with better explosion
        properties. Can inflict great damage.
        Found in the Shi Districts."
    end
    
    def damage(value)
        super(value)
        @speed = 4
        fuse
    end
    
    def fuse_mechanics
        @range = 10000
        @shading -= 0x00000101 if @fuse_counter
        try_to_jump if @fuse_counter == 10
        super()
    end
    
    def at_collision
        @speed = 4
        fuse
    end
    
end
