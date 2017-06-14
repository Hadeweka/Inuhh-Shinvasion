class Comm_Irnovel < Enemy
    
    def activation
        @strength = 5
        @score = 100000
        @speed = 3
        @defense = 3
        @random_jump_delay = 1
        @jump_image = false
        @range = 10000
        #@no_knockback = true
        @world = 5
        @dodge = false
        hpdiff = [4, 6, 8, 10]
        @maxhp = hpdiff[Difficulty.get]
        hpdiff = [2, 3, 4, 5] if @param == 1
        @hp = hpdiff[Difficulty.get]
        @boss = true
        @mindamage = 2
        @ysize = 50
        @jump_speed = -12
        @hunting = true
        @hunt_max_delay = 80
        @border_turn = false
        @abyss_turn = false
        @projectile = true
        @drop = Objects::Key
        @projectile_reload = 314
        @projectile_reload *= 3 if @param == 1
        @strength = 2 if @param == 1
        @projectile_damage = 7
        @projectile_type = Projectiles::Fire
        @projectile_lifetime = 20
        @projectile_offset = [0.0, 15.0]
        @projectile_mechanics = [0.0, 0.0, 0.0, 0.0]
        load_graphic("Comm_Irnovel", 2*@xsize)
        @description = "One of the three Shi commanders. Aims precisely
        and bounces around on a special cannon. Only shots
        in its back, not the cannon, will hurt it. He doesn't
        shoot often, but its cannon is a flamethrower.
        Very enthusiastic about the mission. Maybe a bit too much.
        Resides in the Yunada Ship."
    end
    
    def shoot_projectile
        return if @dir == :left && @inuhh.x > @x || @dir == :right && @inuhh.x < @x
        @speed = 0
        restore_vy = @vy
        @vy = 0
        dvecx = @inuhh.x - (@x + (@dir == :left ? -@xsize : @xsize))
        (-3).upto(3) do |i|
            dvecy = @inuhh.y - (@y - @ysize + 15.0 + i*1.0)
            cosphi = ((@dir == :left ? -1.0 : 1.0)*dvecx / Math::sqrt(dvecx*dvecx + dvecy*dvecy))
            projx = cosphi*12.5
            projy = (@inuhh.y < @y ? -1.0 : 1.0)*Math::sqrt(1-cosphi*cosphi)*(25.0) + i*1.0
            @projectile_mechanics = [projx, projy, 0.0, 0.0]
            super()
        end
        @vy = restore_vy
        @speed = 3
    end
    
    def at_shot(projectile)
        a = (projectile.vx > 0 && @dir == :right) || (projectile.vx < 0 && @dir == :left)
        a &&= (projectile.y < @y-@ysize)
        @dir = (@inuhh.x < @x ? :left : :right)
        return a
    end
    
    def custom_mechanics
        @border_jump_delay = (@hunt_delay < @hunt_max_delay ? nil : 5)
    end
    
end
