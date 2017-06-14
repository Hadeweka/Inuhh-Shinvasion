class Shitor < Enemy
    
    def activation
        @strength = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
        @score = 6000
        @defense = 1
        @world = 2
        @havoc = true
        @phase = 0.0
        @speed = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
        @vp = @speed*1.0
        @abyss_turn = false
        @description = "Weird Shi rolling down hills (and sometimes abysses)
        with a very well kept secret weak spot (its belly).
        Found in forests and uneven places."
        load_graphic("Shitor")
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
            @cur_image.draw_rot(@x, @y-25, ZOrder::Enemies, @phase)
        else
            @cur_image.draw(@x + offs_x, @y - @ysize*2 + 1, ZOrder::Enemies, factor, 1.0)
        end
    end
    
    def custom_mechanics
        @phase += (@dir == :right ? @vp : -@vp)
        @defense = ((120.0..240.0) === @phase % 360.0 ? 0 : 1)
    end
    
end
