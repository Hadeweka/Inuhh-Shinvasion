class Launshi < Enemy
    
    def activation
        @score = 0
        @range = 100000
        @strength = (Difficulty.get > Difficulty::HARD ? 6 : 5)
        @hp = 1
        @speed = 0
        @world = 5
        @defense = 1000
        @riding = true
        @gravity = false
        @projectile_offset = [0.0, @ysize]
        @projectile_mechanics = [0.0, 1.0, 0.0, 0.0]
        @projectile_lifetime = 50
        @projectile_damage = 7
        @projectile = false
        @projectile_type = Projectiles::Fire
        @prepared = -1
        @moving = false
        @jump_image = false
        load_graphic("Launshi")
        @description = "Special Shilevator which can reach the
        highest speeds of all Shi if used. Launches
        up until stopped by liquids or walls, or
        if not used anymore. Can be dangerous if used
        without care, because of its explosive drive.
        Found in and near the Shi Factory."
    end
    
    def custom_mechanics
        @projectile = (@vy < 0) && rand(2) == 0
        @projectile_offset[0] = -rand(2*@xsize)-@xsize/2
        if self == @inuhh.riding_entity then
            if @vy == 0 || @vy == 10 then
                @vy = @prepared
            else
                @vy -= 1 if @vy > -30
            end
        elsif @vy != 0 && (@inuhh.y - @y) > 400 then
            @vy = 10
        elsif @vy != 0 && (@inuhh.y - @y) < -100 then
            @vy = 2
        end
        if @vy != 0 then
            if !would_fit(0, -1) then
                fuse(1)
            elsif !would_fit(0, 1) then
                #@vy = -1	# Whyever this was there... seems unnecessary and buggy
            end
        end
        if !would_fit(0, -1) then
            fuse(1)
        end
        if @map.water(@x, @y) then
            @vy += 5 if @vy < 0
            @vy = 0 if @vy.abs < 5
        end
    end
    
end
