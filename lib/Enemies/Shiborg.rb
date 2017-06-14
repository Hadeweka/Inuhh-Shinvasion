class Shiborg < Enemy
    
    def activation
        @score = 15000
        @world = 4
        @hp = 14
        @defense = (Difficulty.get > Difficulty::NORMAL ? 2 : 1)
        @strength = 5
        @xsize = 50
        @ysize = 50
        @speed = 1
        @projectile = true
        @projectile_type = Projectiles::Laser
        @projectile_reload = 67
        @projectile_damage = 3
        @projectile_offset = [0.0, 0.0]
        @projectile_mechanics = [10.0, 1.0, 0.0, 0.0]
        load_graphic("Shiborg")
        @description = "Mechanical Shi with an invisible laser gun.
        Quite bulky and not too small.
        Doesn't make much damage, though.
        Is used in Shi spacecrafts and factories."
    end
    
end
