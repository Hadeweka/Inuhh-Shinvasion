class Big_Shi < Enemy
    
    def activation
        @strength = 1
        @mindamage = 1
        @drop = Objects::Key
        @hp = 5
        @range = 100000
        @maxhp = 5
        @defense = 1000
        @boss = true
        @random_jump_delay = 50
        @world = 6
        @xsize = 50
        @ysize = 50
        @speed = 9
        @stunned = false
        @stunned_time = 200
        @score = 0
        @inventory = nil
        @hunting = true
        @projectile = true
        @border_turn = false
        @projectile_type = Projectiles::Doom_Ball
        @projectile_damage = 4
        @projectile_reload = Difficulty.get > Difficulty::NORMAL ? rand(1000) + 200 : 500 + rand(1000)
        @projectile_mechanics = [5.0+rand*5.0, -5.0-rand*5.0, 0.0, 1.0]
        @projectile_offset = [0.0, -@ysize+3.0]
        @berserk = false
        load_graphic("Big_Shi")
        @description = "T"
    end
    
    def go_berserk
        @berserk = true
    end
    
    def at_shot(projectile)
        if projectile.type == Projectiles::Ball then
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
        end
    end
    
    def damage(value)
        super(value)
        @window.gems.push(Object_Datas::C_Index[@inventory].new(@window.valimgs[@inventory], (@x/50).floor * 50 + 25, (@y/50).floor * 50 + 50)) if @inventory
        @stunned = @stunned_time
        @inventory = nil
    end
    
    def at_collision
        if !@stunned && @inuhh.item && @inuhh.item.is_a?(CollectibleBall) then
            @inventory = Objects::Ball
            @window.enemies.each do |e|
                next if e == self
                e.prevent_inventory if e.is_a?(Baskeshi) || e.is_a?(Big_Shi)
            end
            @inuhh.delete_items
        end
    end
    
    def prevent_inventory
        @stunned = 5
    end
    
    def custom_mechanics
        @projectile_damage = (@inventory ? 0 : 6)
        if @stunned then
            @stunned -= 1
            @stunned = false if @stunned == 0
        else
            collect_balls
        end
        @projectile_type = @inventory ? Projectiles::Ball : Projectiles::Doom_Ball
        @speed = [5,6,7,8,9].sample if rand(50) == 0
        @projectile_reload = Difficulty.get > Difficulty::NORMAL ? rand(1000) + 200 : 500 + rand(1000)
        @projectile_mechanics = [5.0+rand*10.0, -5.0-rand*10.0, 0.0, 1.0]
        @projectile_reload = 5 if @berserk
        @projectile_damage = 666 if @berserk
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
    
    def shoot_projectile
        if @inventory then
            @dir = @dir == :left ? :right : :left
            @inventory = nil
        end
        dirfac = (@dir == :left ? -1.0 : 1.0)
        @window.spawn_projectile(@projectile_type, @x.to_f+(Projectiles::XSizes[@projectile_type]+@xsize)*dirfac+@projectile_offset[0]*dirfac,
                                 @y.to_f-@ysize.to_f-Projectiles::YSizes[@projectile_type]+@projectile_offset[1],
                                 @projectile_mechanics[0]*dirfac+@speed*dirfac.to_f, @projectile_mechanics[1],
                                 *@projectile_mechanics[2..3], @projectile_owner, @projectile_lifetime, @projectile_damage)
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
            @window.valimgs[@inventory].draw(@x + (@dir == :left ? -75 : 25), @y - 125, ZOrder::UI)
        end
    end
    
end
