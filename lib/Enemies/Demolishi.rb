class Demolishi < Enemy
    
    def activation
        @hp = 5
        @strength = (Difficulty.get > Difficulty::EASY ? 5 : 4)
        @score = 13000
        @defense = 3
        @world = 4
        @havoc = true
        @phase = 0.0
        @speed = 3
        @vp = @speed*1.0
        @abyss_turn = false
        load_graphic("Demolishi")
        @description = "Very strong and rampaged Shitor variant.
        Rolls also much faster than a Shitor.
        Prefers dark caves and mountains."
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
        @defense = ((120.0..240.0) === @phase % 360.0 ? 0 : 3)
    end
    
end
