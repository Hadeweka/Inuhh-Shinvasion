class Rampashi < Enemy # Jumping is not a good idea
    attr_reader :top, :bottom
    attr_accessor :x, :vulnerable
    
    def activation
        @score = 6000
        @top = nil
        @bottom = nil
        @speed = 3
        @mindamage = 1
        @rampashi_counter = 9
        @vulnerable = 9
        @abyss_turn = false
        @world = 4
        @defense = 0
        @reduction = 1
        @range = 100000
        @drop = Objects::Key
        @shield_image = Image.new("media/special/Shield5050.png", tileable: true)
        @strength = (Difficulty.get >= Difficulty::NORMAL ? (Difficulty.get == Difficulty::DOOM ? 10 : 7) : 5)
        @mindamage = (Difficulty.get >= Difficulty::NORMAL ? (Difficulty.get == Difficulty::DOOM ? 5 : 3) : 2)
        @hp = (Difficulty.get == Difficulty::EASY ? 3 : (Difficulty.get < Difficulty::DOOM ? 4 : 5))
        @projectile = false
        @projectile = true if SHIPEDIA
        @projectile_reload = 350
        @projectile_damage = 7
        @projectile_type = Projectiles::Fire
        @projectile_offset = [0.0, 0.0]
        @projectile_mechanics = [3.0, 0.0, 0.0, 0.0]
        @maxhp = @hp
        @boss = true
        @xsize = 50
        @ysize = 50
        load_graphic("Rampashi")
        @description = "Oversized variant of the Shillar. Protects all
        but one of its components with a special damage
        reflecting shield. Also can easily be angered.
        Usually consists of 10 Shi segments.
        This dangerous Shi is kept secret in the
        Westton Base inside the Westton Mountain."
        
    end
    
    def draw
        super()
        @shield_image.draw(@x-@xsize-50, @y-2*@ysize-50, ZOrder::Enemies) if @defense == 1000
    end
    
    def set_top(enemy)
        @top = enemy
    end
    
    def set_bottom(enemy)
        @bottom = enemy
    end
    
    def custom_mechanics
        spawn_on_top
        pillar {|e| e.x = bottommost.x}
        send_vulnerable(@vulnerable)
        if position == @vulnerable then
            @defense = 0
        else
            @defense = 1000
        end
        if topmost == bottommost then
            @drop = Objects::Key
            @speed = 7
        else
            @drop = nil
        end
        if @vulnerable >= count then
            @vulnerable = rand(count)
            send_vulnerable(@vulnerable)
        end
    end
    
    def position
        return count-count_above
    end
    
    def projectile_mechanics
        super()
        @projectile_reload = rand(100-(@maxhp-2+@hp)*5)+(Difficulty.get > Difficulty::NORMAL ? 200 : 300)
        @projectile_reload = 30 if bottommost == topmost
    end
    
    def damage(value)
        super(value)
        if @inuhh.x < @x && @dir == :right || @inuhh.x > @x && @dir == :left then
            switch_dir
        end
        if value > 0 then
            @vulnerable = rand(count)
            send_vulnerable(@vulnerable)
            @projectile = true if @hp < @maxhp-1
        elsif @defense == 1000 then
            @projectile_type = Projectiles::Laser
            @projectile_mechanics = [30.0, 0.0, 0.0, 0.0]
            @projectile_offset = [0.0, -25.0]
            shoot_projectile
            @projectile_offset = [0.0, 0.0]
            shoot_projectile
            @projectile_offset = [0.0, 25.0]
            shoot_projectile
            @projectile_type = Projectiles::Fire
            @projectile_offset = [0.0, 0.0]
            @projectile_mechanics = [3.0, 0.0, 0.0, 0.0]
        end
    end
    
    def switch_dir
        pillar {|e| e.real_switch_dir}
    end
    
    def send_vulnerable(v)
        pillar {|e| e.vulnerable = v}
    end
    
    def above_pillar
        ind = self
        while ind do
            yield ind
            ind = ind.top
        end
    end
    
    def count
        ind = 0
        pillar {|e| ind += 1}
        return ind
    end
    
    def count_above
        ind = 0
        above_pillar {|e| ind += 1}
        return ind
    end
    
    def pillar
        ind = self
        while ind do
            yield ind
            ind = ind.top
        end
        ind = self.bottom
        while ind do
            yield ind
            ind = ind.bottom
        end
    end
    
    def at_death
        @top.set_bottom(@bottom) if @bottom && @top
        @bottom.set_top(@top) if @bottom && @top
        @top.set_bottom(nil) if !@bottom && @top
        @bottom.set_top(nil) if @bottom && !@top
    end
    
    def real_switch_dir
        @dir = (@dir == :left ? :right : :left) if !would_fit(0, 1) || !@gravity || @air_control || @bottom
    end
    
    def set_counter(value)
        @rampashi_counter = value
    end
    
    def spawn_on_top
        while @rampashi_counter > 0 do
            ne = @window.spawn_enemy(Enemies::Rampashi, @x+(@dir == :left ? @speed : -@speed), topmost.y-2*topmost.ysize, @dir)
            ne.set_bottom(topmost)
            topmost.set_top(ne)
            ne.set_counter(0)
            @rampashi_counter -= 1
        end
    end
    
    def topmost
        if @top then
            return @top.topmost
        else
            return self
        end
    end
    
    def bottommost
        if @bottom then
            return @bottom.bottommost
        else
            return self
        end
    end
    
    def gravity_mechanics
        @vy += 1 if @gravity
        # Vertical movement
        if @vy > 0 then
            @vy.to_i.times { if would_fit(0, 1) then @y += 1 else @vy = 0 end }
        end
        if @vy < 0 then
            (-@vy).to_i.times { if would_fit(0, -1) then @y -= 1 else @vy = 0 end }
        end
    end
    
    def would_fit(offs_x, offs_y)
        return true if @through
        return false if offs_y > 0 && @bottom && @y >= @bottom.y - 2*@bottom.ysize
        # Check at the center/top and center/bottom for map collisions
        expr = true
        0.upto((@ysize/25).floor) do |t|
            ((-@xsize/50)+1).floor.upto((@xsize/50).floor) do |u|
                edge_y = t == 0 ? 0 : 1
                edge_x = 0
                expr &&= !@map.solid?(@x + offs_x + 25 - (@xsize>25 ? 25 : 0) + u*50 - edge_x, @y + offs_y - 50*(t) + edge_y)
                expr &&= !@map.solid?(@x + offs_x - 24 - (@xsize>25 ? 25 : 0) + u*50 - edge_x, @y + offs_y - 50*(t) + edge_y)
            end
        end
        return expr
    end
    
    def border_mechanics
        if (!would_fit(1, 0) && @dir == :right) || (!would_fit(-1, 0) && @dir == :left) then
            if !@border_jump_delay then
                switch_dir if @border_turn && @vy == 0
            elsif !random_jump(@border_jump_delay) then
                switch_dir if @border_turn && @vy == 0
            end
        end
    end
    
    def abyss_mechanics
        if would_fit((@dir == :left ? -@xsize : @xsize), 1) && !@jumping then
            if !@abyss_jump_delay || @vy != 0 || (@hunting && @inuhh.y > @y) || !random_jump(@abyss_jump_delay) then
                switch_dir if @abyss_turn
            end
        end
    end
    
end
