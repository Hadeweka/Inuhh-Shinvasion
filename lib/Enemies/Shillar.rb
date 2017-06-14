class Shillar < Enemy # Jumping is not a good idea
    attr_reader :top, :bottom
    attr_accessor :x
    
    def activation
        @score = 2000
        @top = nil
        @bottom = nil
        @speed = 2
        @mindamage = 1
        @shillar_counter = (@param ? @param : 4)
        @abyss_turn = false
        @world = 3
        load_graphic("Shillar")
        @description = "Forms stable Shi towers consisting
        of 2 or more Shillars. Defeating one
        won't break this tower but make it smaller.
        Can be found on many places."
    end
    
    def set_top(enemy)
        @top = enemy
    end
    
    def set_bottom(enemy)
        @bottom = enemy
    end
    
    def custom_mechanics
        spawn_on_top
        @abyss_turn = !@bottom
        pillar {|e| e.x = bottommost.x}
    end
    
    def switch_dir
        pillar {|e| e.real_switch_dir}
    end
    
    def above_pillar
        ind = self
        while ind do
            yield ind
            ind = ind.top
        end
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
        @shillar_counter = value
    end
    
    def spawn_on_top
        while @shillar_counter > 0 do
            ne = @window.spawn_enemy(Enemies::Shillar, @x+(@dir == :left ? @speed : -@speed), topmost.y-2*topmost.ysize, @dir)
            ne.set_bottom(topmost)
            topmost.set_top(ne)
            ne.set_counter(0)
            @shillar_counter -= 1
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
