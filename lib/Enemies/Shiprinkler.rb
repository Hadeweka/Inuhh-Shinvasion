class Shiprinkler < Enemy
    
    def activation
        @score = 12000
        @strength = 3
        @hp = 10
        @defense = 2
        @world = 5
        @speed = 1
        @projectile = false
        @waterproof = true
        @projectile_reload = 0
        @projectile_damage = 1
        @projectile_owner = Projectiles::RAMPAGE
        @projectile_type = Projectiles::Water
        @projectile_offset = [0.0, -@ysize+3.0]
        @projectile_mechanics = [0.0, 0.0, 0.0, 0.0]
        @hyashi = nil # Can be Inuhh aswell
        @hyashi_stored = false
        load_graphic("Shiprinkler")
        @description = "This Shi isn't lile most other Shi. It waters
        Hyashis to heal them. If someone kills one of its
        precious Hyashis it will get very angry.
        However, it still only shoots water.
        Lives in the Shi Sanatorium."
    end
    
    def shoot_projectile
        @speed = 0
        restore_vy = @vy
        @vy = 0
        dvecx = @hyashi.x - (@x + (@dir == :left ? -@xsize : @xsize))
        dvecy = @hyashi.y - (@y - 2*@ysize + 3.0)
        cosphi = ((@dir == :left ? -1.0 : 1.0)*dvecx / Math::sqrt(dvecx*dvecx + dvecy*dvecy))
        projx = cosphi*10.0 + rand(10)*1.0
        projy = (@hyashi.y < @y ? -1.0 : 1.0)*Math::sqrt(1-cosphi*cosphi)*(10.0+rand(10)*1.0)
        @projectile_mechanics = [projx, projy, 0.0, 0.1]
        super()
        @vy = restore_vy
        @speed = (@hyashi == @inuhh ? (Difficulty.get > Difficulty::NORMAL ? 6 : 5) : 1)
    end
    
    def move_mechanics
        if @hyashi then
            if @hunt_delay >= @hunt_max_delay then
                if @dodge then
                    if @hyashi.x - @x < -100*@dodge_range then
                        @dir = :left if @vy == 0 || @air_control || @waterproof
                    elsif @hyashi.x - @x > 100*@dodge_range
                        @dir = :right if @vy == 0 || @air_control || @waterproof
                    end
                else
                    @dir = (@hyashi.x < @x ? :left : :right)
                end
                @hunt_delay = 0
            end
            @hunt_delay += 1
        end
        super()
    end
    
    def custom_mechanics
        nearest = 1000
        if !@hyashi_stored then
            @window.enemies.each do |e|
                if e.is_a?(Hyashi) && (e.x - @x).abs < 300 && (e.y - @y).abs < 100 && nearest > (e.x - @x) && e.living then
                    @hyashi = e
                    @hyashi_stored = true
                    nearest = (e.x - @x).abs
                    @abyss_turn = false
                    @border_turn = false
                end
            end
        end
        if @hyashi then
            try_to_jump if @hyashi.y < @y
        end
        if @hyashi && @hyashi != @inuhh && @hyashi.flowerful then
            @hyashi = nil
            @hyashi_stored = false
            @abyss_turn = true
            @border_turn = true
        end
        if @hyashi_stored && @hyashi != @inuhh && !@hyashi.living && !@hyashi.flowerful then
            @hyashi = @inuhh
            @speed = (Difficulty.get > Difficulty::NORMAL ? 6 : 5)
            @strength = 10
        end
        @projectile = @hyashi && ((@hyashi.x < @x && @dir == :left) || (@hyashi.x > @x && @dir == :right)) && (@hyashi.x - @x).abs >= 50
    end
    
end
