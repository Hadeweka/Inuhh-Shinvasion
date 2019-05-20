class Avalanshi < Enemy
    
    def activation
        @strength = (Difficulty.get == Difficulty::DOOM ? 10 : 9)
        @score = 27000
        @defense = 5
        @reduction = 1
        @hp = 20
        @world = 6
        @havoc = true
        @phase = 0.0
        @xsize = 100
        @ysize = 100
        @shading = 0xff88ff88 if @param == 1
        @speed = (Difficulty.get == Difficulty::DOOM ? 5 : 4)
        @vp = 2.0
        @abyss_turn = false
        @description = "T"
        load_graphic("Avalanshi")
    end
    
    def draw
        return if @invisible && !EDITOR
        if @dir == :left then
            offs_x = -@xsize
            factor = 1.0
        else
            offs_x = @xsize
            factor = -1.0
        end
        if !EDITOR then
            @cur_image.draw_rot(@x, @y-@ysize, ZOrder::Enemies, @phase, 0.5, 0.5, 1, 1, @shading)
        else
            @cur_image.draw(@x + offs_x, @y - @ysize*2 + 1, ZOrder::Enemies, factor, 1.0, @shading)
        end
    end
    
    def custom_mechanics
        @phase += (@dir == :right ? @vp : -@vp)
        @defense = ((120.0..240.0) === @phase % 360.0 ? 3 : 5)
    end
    
end
