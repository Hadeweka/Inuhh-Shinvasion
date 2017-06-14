class Comm_Unhorqh < Enemy
    
    def activation
        @strength = 6
        @score = 100000
        @speed = 7
        @defense = 3
        @jump_image = false
        @range = 10000
        @world = 5
        hpdiff = [3, 4, 5, 6]
        @maxhp = hpdiff[Difficulty.get]
        hpdiff = [2, 3, 4, 5] if @param == 1
        @hp = hpdiff[Difficulty.get]
        @boss = true
        @air_control = true
        @hunting = true
        @mindamage = 2
        @random_jump_delay = 20
        @hunt_max_delay = 80
        @border_turn = false
        @abyss_turn = false
        @projectile = true
        @drop = Objects::Key
        @projectile_reload = 171
        @projectile_reload *= 2 if @param == 1
        @strength = 2 if @param == 1
        @projectile_damage = 5
        @projectile_type = Projectiles::Laser
        @projectile_offset = [0.0, -@ysize+3.0]
        @projectile_mechanics = [0.0, 0.0, 0.0, 0.0]
        load_graphic("Comm_Unhorqh")
        @description = "One of the three Shi commanders. Aims precisely
        and flies around erratically. Only shots in its back
        will hurt it. Has high speed and is hard to hit.
        It was promoted the rank of a commander because it
        somehow managed to destroy a whole legion of Shi.
        Resides in the Yunada Ship."
    end
    
    def try_to_jump
        @vy = -10
        @jumping = true
    end
    
    def shoot_projectile
        return if @dir == :left && @inuhh.x > @x || @dir == :right && @inuhh.x < @x
        @speed = 0
        restore_vy = @vy
        @vy = 0
        dvecx = @inuhh.x - (@x + (@dir == :left ? -@xsize : @xsize))
        dvecy = @inuhh.y - (@y - 2*@ysize + 3.0)
        cosphi = ((@dir == :left ? -1.0 : 1.0)*dvecx / Math::sqrt(dvecx*dvecx + dvecy*dvecy))
        projx = cosphi*30.0
        projy = (@inuhh.y < @y ? -1.0 : 1.0)*Math::sqrt(1-cosphi*cosphi)*(25.0+rand(20)*1.0)
        @projectile_mechanics = [projx, projy, 0.0, 0.0]
        super()
        @vy = restore_vy
        @speed = 10
    end
    
    def at_shot(projectile)
        a = (projectile.vx > 0 && @dir == :right) || (projectile.vx < 0 && @dir == :left)
        @dir = (@inuhh.x < @x ? :left : :right)
        return a
    end
    
end
