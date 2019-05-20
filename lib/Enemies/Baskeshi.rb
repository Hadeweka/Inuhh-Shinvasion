class Baskeshi < Enemy
    
    def activation
        @strength = 5
        @hp = 11
        @defense = 10
        @world = 6
        @stunned = false
        @speed = 2
        @score = 22000
        @nearest = nil
        @inventory = nil
        if @param && @param != 0 then
            @boss_mode = true
            @hostile = (@param == 1 ? true : false)
        else
            @boss_mode = false
        end
        @stunned_time = 300
        @dangerous = @hostile
        @hunting = !@boss_mode
        @shading = 0xff00ffff if !@hostile
        @projectile = @boss_mode ? false : true
        @border_turn = false
        @projectile_type = Projectiles::Ball
        @range = 100000 if @boss_mode
        @strength = 0 if @boss_mode
        @speed_plus = 0
        @defense = 1000 if @boss_mode
        @random_jump_delay = 50 if @hostile
        @jump_speed = -20 if @hostile
        @projectile_damage = 3
        @projectile_reload = rand(200) + 100
        @projectile_mechanics = [5.0+rand*5.0, -5.0-rand*5.0, 0.0, 1.0]
        @projectile_offset = [0.0, -@ysize+3.0]
        load_graphic("Baskeshi")
        @description = "T"
    end
    
    def prevent_inventory
        @stunned = 5
    end
    
    def draw
        return if @invisible && !EDITOR
        # Flip vertically when facing to the left.
        if @dir == :left then
            offs_x = -@xsize
            factor = 1.0
        else
            offs_x = @xsize
            factor = -1.0
        end
        if EDITOR then
            @cur_image = @standing if !@moving && !@dir_set
            @cur_image.draw(@x + offs_x, @y - @ysize*2 + 1, ZOrder::Enemies, factor, 1.0, @shading)
        else
            distance = 200.0
            factor = 1.0 if !@moving && !@dir_set
            zxsize = @xsize*1.0/(1.0 + @z/distance)
            zysize = @ysize*1.0/(1.0 + @z/distance)
            zord = (@z < 0 ? ZOrder::Foreground : ZOrder::Enemies)
            @cur_image.draw(@x - factor*zxsize, @y - zysize*2 + 1 + zysize-@ysize, zord, factor*zxsize/@xsize, zysize/@ysize, @shading)
        end
        if @inventory then
            @window.valimgs[@inventory].draw(@x + (@dir == :left ? -50 : 0), @y - 75, ZOrder::UI)
        end
    end
    
    def custom_mechanics
        if @boss_mode then
            if @stunned then
                @stunned -= 1
                @stunned = false if @stunned == 0
            else
                collect_balls
            end
        end
        @projectile_reload = rand(200) + 100
        @projectile_mechanics = [5.0+rand*10.0, -5.0-rand*10.0, 0.0, 1.0]
        @nearest = nil if @nearest && @nearest != @inuhh && !@nearest.living
        if !@inventory then
            @random_jump_delay = 50 if @hostile
            @speed_plus = [0, 1, 2].sample if @boss_mode && rand(20) == 0
            @speed = 2 + @speed_plus + (@hostile && @inuhh.x >= 100*50/2 ? (@inuhh.x > @x + 30*50 ? 7 : 5) : 0)
            @nearest = @inuhh
        else
            if @hostile then
                @speed = 6
                @random_jump_delay = 0
                @nearest = nil
                @dir = :left
                @window.enemies.each do |e|
                    next unless e.is_a?(Shicore) && e.x <= 500
                    if (@x - e.x) <= 230 then
                        @dir = :right
                    elsif (@x - e.x) <= 250 then
                        @speed = 0
                        @projectile_owner = Projectiles::RAMPAGE
                        @projectile_mechanics = [10.0, -25.0, 0.0, 1.0]
                        shoot_projectile
                        @inventory = nil
                    end
                    break
                end
            else
                @speed = 6
                @dir = (@inuhh.x < @x ? :left : :right)
            end
        end
    end
    
    def at_collision
        if @hostile && @inuhh.item && @inuhh.item.is_a?(CollectibleBall) && !@stunned then
            @inventory = Objects::Ball
            @window.enemies.each do |e|
                next if e == self
                e.prevent_inventory if e.is_a?(Baskeshi) || e.is_a?(Big_Shi)
            end
            @inuhh.delete_items
        end
    end
    
    def damage(value)
        super(value)
        if @boss_mode then
            @window.gems.push(Object_Datas::C_Index[@inventory].new(@window.valimgs[@inventory], (@x/50).floor * 50 + 25, (@y/50).floor * 50 + 50)) if @inventory
            @stunned = @stunned_time
            @inventory = nil
        end
    end
    
    def at_shot(projectile)
        if projectile.type == Projectiles::Ball then
            if @boss_mode then
                if !@stunned then
                    @inventory = Objects::Ball
                    @window.enemies.each do |e|
                        next if e == self
                        e.prevent_inventory if e.is_a?(Baskeshi) || e.is_a?(Big_Shi)
                    end
                    @invul = 1
                else
                    @window.gems.push(Object_Datas::C_Index[@inventory].new(@window.valimgs[@inventory], (@x/50).floor * 50 + 25, (@y/50).floor * 50 + 50)) if @inventory
                end
            else
                dv = 1
                damage(dv)
                @window.messages.push([dv, @x-@xsize+10, @y-@ysize-30, 20, true, 2.0+(dv-1)/30.0, 2.0+(dv-1)/30.0, 0xff00ff00])
            end
        end
    end
    
    def collect_balls
        @window.gems.reject! do |c|
            if c.is_a?(CollectibleBall) && (c.x - @x).abs < 2*@xsize && (c.y - @y + @ysize).abs < 2*@ysize
                @inventory = Objects::Ball
                @window.enemies.each do |e|
                    next if e == self
                    e.prevent_inventory if e.is_a?(Baskeshi) || e.is_a?(Big_Shi)
                end
                true
            else
                false
            end
        end
    end
    
    def move_mechanics
        if @boss_mode && @nearest then
            if @hunt_delay >= @hunt_max_delay then
                if @dodge then
                    if @nearest.x - @x < -100*@dodge_range then
                        @dir = :left if @vy == 0 || @air_control || @waterproof
                    elsif @nearest.x - @x > 100*@dodge_range
                        @dir = :right if @vy == 0 || @air_control || @waterproof
                    end
                else
                    @dir = (@nearest.x < @x ? :left : :right)
                end
                @hunt_delay = 0
            end
            @hunt_delay += 1
        end
        super()
    end
    
end
