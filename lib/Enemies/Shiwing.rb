class Shiwing < Enemy
    
    def activation
        @riding = true
        @score = 8000
        @world = 6
        @angle = 0.0
        @strength = 3
        @hp = 1
        @defense = 2
        @a_speed = 0.05
        @speed = 0
        @x_0 = @x
        @y_0 = @y
        @range = 10000
        @asignum = 1.0
        if @param then
            @va = @param*0.5*(@dir == :left ? -1 : 1)
        else
            @va = 3.0*(@dir == :left ? -1 : 1)
        end
        @speed = 3 if SHIPEDIA
        @through = true if SHIPEDIA
        @gravity = false
        @abyss_turn = false
        @ysize = 150 if SHIPEDIA
        load_graphic("Shiwing", @xsize, (SHIPEDIA ? @ysize : 6*@ysize))
        @description = "Rideable Shi pendulum. Can swing with
        different velocities.
        Found on Horror Island."
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
            @cur_image.draw_rot(@x - 5*@xsize*Math::sin(@angle/180.0*Math::PI), @y - 5*@ysize*Math::cos(@angle/180.0*Math::PI) - @ysize, ZOrder::Enemies, -@angle)
        else
            @cur_image.draw(@x + offs_x, @y - @ysize*2 + 1 - 250, ZOrder::Enemies, factor, 1.0)
        end
    end
    
    def custom_mechanics
        @va -= @a_speed*@a_speed*@angle
        @angle += @va*@asignum
        if false then
            
        else
            @x = @x_0 + 2*6*@xsize*Math::sin(@angle/180.0*Math::PI)
            @y = @y_0 + 2*6*@ysize*Math::cos(@angle/180.0*Math::PI) - 300
        end
    end
    
end
