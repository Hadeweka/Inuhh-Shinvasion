class Shinsaw < Enemy
    
    def activation
        @strength = (Difficulty.get == Difficulty::DOOM ? 7 : 6)
        @spike_strength = (Difficulty.get == Difficulty::DOOM ? 7 : 6)
        @spike = true
        @mindamage = 3
        @minsdamage = 3
        @score = 14000
        @havoc = true
        @hp = 3
        @defense = 3
        @world = 5
        @phase = 0.0
        @random_jump_delay = 50
        @jump_speed = -10
        @jump_image = false
        @speed = 7
        @vp = @speed*1.0
        @abyss_turn = false
        load_graphic("Shinsaw")
        @description = "Fast and dangerous rolling Shi with spikes.
        Can also make small but deadly leaps.
        Found in the Shi Factory."
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
    end
    
end
