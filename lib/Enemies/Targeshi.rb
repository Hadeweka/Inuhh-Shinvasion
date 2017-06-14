class Targeshi < Enemy
    
    def activation
        @score = 15000
        @strength = 4
        @hp = 8
        @defense = 3
        @hunting = true
        @border_turn = false
        @abyss_turn = false
        @world = 5
        @speed = 1
        @projectile = true
        @projectile_reload = (Difficulty.get > Difficulty::EASY ? 47 : 67)
        @projectile_damage = 4
        @projectile_type = Projectiles::Laser
        @projectile_offset = [0.0, -@ysize+3.0]
        @projectile_mechanics = [0.0, 0.0, 0.0, 0.0]
        load_graphic("Targeshi")
        @description = "This fierce Shistol variant aims much
        better than most other Shi. Also doesn't
        shoot only horizontally. Can be tricked due to
        its constant shooting interval, however.
        Operates in hidden but important Shi facilities."
    end
    
    def shoot_projectile
        @speed = 0
        restore_vy = @vy
        @vy = 0
        dvecx = @inuhh.x - (@x + (@dir == :left ? -@xsize : @xsize))
        dvecy = @inuhh.y - (@y - 2*@ysize + 3.0)
        cosphi = ((@dir == :left ? -1.0 : 1.0)*dvecx / Math::sqrt(dvecx*dvecx + dvecy*dvecy))
        projx = cosphi*30.0
        projy = (@inuhh.y < @y ? -1.0 : 1.0)*Math::sqrt(1-cosphi*cosphi)*(25.0+rand(10)*1.0)
        @projectile_mechanics = [projx, projy, 0.0, 0.0]
        super()
        @vy = restore_vy
        @speed = 1
    end
    
end
