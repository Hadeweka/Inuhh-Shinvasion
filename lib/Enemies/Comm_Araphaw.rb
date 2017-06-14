class Comm_Araphaw < Enemy
    
    def activation
        @strength = 8
        @score = 100000
        @speed = 2
        @defense = 3
        @range = 10000
        @world = 5
        @dodge = false
        hpdiff = [5, 8, 10, 12]
        @maxhp = hpdiff[Difficulty.get]
        hpdiff = [2, 3, 4, 5] if @param == 1
        @hp = hpdiff[Difficulty.get]
        @boss = true
        @spike = true
        @spike_strength = 10
        @ysize = 50
        @hunting = true
        @hunt_max_delay = 60
        @mindamage = 2
        @minsdamage = 5
        @border_turn = false
        @abyss_turn = false
        @projectile = true
        @drop = Objects::Key
        @projectile_reload = 131
        @projectile_reload *= 2 if @param == 1
        @strength = 2 if @param == 1
        @projectile_damage = 5
        @projectile_type = Projectiles::Laser
        @projectile_offset = [0.0, -@ysize+58.0]
        @projectile_mechanics = [0.0, 0.0, 0.0, 0.0]
        load_graphic("Comm_Araphaw", 2*@xsize)
        @description = "One of the three Shi commanders. Aims precisely
        and has got a sharp spike. Only shots in its back
        will hurt it. Has high health and strength.
        It is very proud of its spike and devoted to Admiral
        Aromtharag because he granted the use of it.
        Resides in the Yunada Ship."
    end
    
    def shoot_projectile
        return if @dir == :left && @inuhh.x > @x || @dir == :right && @inuhh.x < @x
        @speed = 0
        restore_vy = @vy
        @vy = 0
        dvecx = @inuhh.x - (@x + (@dir == :left ? -@xsize : @xsize))
        dvecy = @inuhh.y - (@y - 2*@ysize + 58.0)
        cosphi = ((@dir == :left ? -1.0 : 1.0)*dvecx / Math::sqrt(dvecx*dvecx + dvecy*dvecy))
        projx = cosphi*30.0
        projy = (@inuhh.y < @y ? -1.0 : 1.0)*Math::sqrt(1-cosphi*cosphi)*(25.0+rand(15)*1.0)
        @projectile_mechanics = [projx, projy, 0.0, 0.0]
        super()
        @vy = restore_vy
        @speed = 2
    end
    
    def at_shot(projectile)
        a = (projectile.vx > 0 && @dir == :right) || (projectile.vx < 0 && @dir == :left)
        @dir = (@inuhh.x < @x ? :left : :right)
        return a
    end
    
    def custom_mechanics
        @border_jump_delay = (@hunt_delay < @hunt_max_delay ? nil : 5)
    end
    
end
