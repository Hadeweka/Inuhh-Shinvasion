class Shindulum < Enemy
    
    def activation
        @strength = (Difficulty.get == Difficulty::DOOM ? 8 : 7)
        @spike_strength = (Difficulty.get == Difficulty::DOOM ? 8 : 7)
        @mindamage = 3
        @minsdamage = 3
        @spike = true
        @score = 16000
        @hp = 5
        @defense = 4
        @world = 5
        @angle = 0.0
        @a_speed = 0.05
        @va = 2.0*(@dir == :left ? -1 : 1)
        @va *= 4.0 if @param == 1
        @speed = 0
        @x_0 = @x
        @y_0 = @y
        @range = 10000
        @asignum = 1.0
        @speed = 2 if SHIPEDIA
        @through = true if SHIPEDIA
        @gravity = false
        @abyss_turn = false
        @ysize = 100 if SHIPEDIA
        load_graphic("Shindulum", @xsize, (SHIPEDIA ? @ysize : 4*@ysize))
        @description = "Very strong Shi pendulum with spikes.
        Swings periodically and in the foreground
        to not get hit by walls.
        Hangs around in the Shi Factory."
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
        if !EDITOR then
            @cur_image.draw_rot(@x - 3*@xsize*Math::sin(@angle/180.0*Math::PI), @y - 3*@ysize*Math::cos(@angle/180.0*Math::PI) - @ysize, ZOrder::Enemies, -@angle)
        else
            @cur_image.draw(@x + offs_x, @y - @ysize*2 + 1 - 150, ZOrder::Enemies, factor, 1.0)
        end
    end
    
    def custom_mechanics
        if @centrum then
            @x_0 = @centrum.x
            @y_0 = @centrum.y + 8*@ysize
            @dir = @centrum.dir
            if @param == 1 then
                @va = 2.0*(@dir == :left ? -1 : 1)
                @va *= 4.0
            end
        end
        if @param == 1 then
            @angle += @va*@asignum
        else
            @va -= @a_speed*@a_speed*@angle
            @angle += @va*@asignum
        end
        if false #!would_fit(@x_0 - @x + 8*@xsize*Math::sin(@angle/180.0*Math::PI), @y_0 - @y + 8*@ysize*Math::cos(@angle/180.0*Math::PI) - 200) then
            # @asignum *= -1.0
            # Doesn't work... q_q
        else
            @x = @x_0 + 8*@xsize*Math::sin(@angle/180.0*Math::PI)
            @y = @y_0 + 8*@ysize*Math::cos(@angle/180.0*Math::PI) - 200
        end
    end
    
    def bind(enemy)
        @centrum = enemy
    end
    
end
