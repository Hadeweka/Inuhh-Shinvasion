class Shinge < Enemy
    
    def activation
        @strength = (Difficulty.get == Difficulty::DOOM ? 8 : 7)
        @score = 18000
        @hp = 9
        @defense = 5
        @world = 6
        @havoc = true
        @phase = 0.0
        @speed = 1
        @vp = @speed*1.0
        @spike = true
        @spike_strength = (Difficulty.get == Difficulty::DOOM ? 8 : 7)
        @mindamage = 4
        @minsdamage = 4
        @abyss_turn = false
        @description = "T"
        load_graphic("Shinge")
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
        if((90.0..270.0) === @phase % 360.0) then
            @defense = 4
            @spike = false
            @spike_strength = 0
        else
            @defense = 5
            @spike = true
            @spike_strength = (Difficulty.get == Difficulty::DOOM ? 8 : 7)
        end
    end
    
end
