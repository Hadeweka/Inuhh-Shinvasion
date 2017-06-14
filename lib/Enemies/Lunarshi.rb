class Lunarshi < Enemy
    
    def activation
        @speed = 1
        @hp = 12
        @strength = (Difficulty.get > Difficulty::NORMAL ? 7 : 6)
        @defense = 1
        @gravity = false
        @air_control = true
        @score = 16000
        @world = 5
        @abyss_turn = false
        @phase = -25.0
        @phase_dir = -1
        @darkness = Image.new("media/special/Darksphere.png", tileable: true)
        @halo = Image.new("media/special/Halo.png", tileable: true)
        load_graphic("Lunarshi")
        @description = "Special floating Shi with phases like the moon
        because of a dark convoying sphere. If not coverd
        it will emit a strong light. Has high health and
        strength, but isn't very fast.
        Floating around on the Shi Trail."
    end
    
    def draw
        @darkness.draw(@x-@xsize+@phase, @y-@ysize-25+1, ZOrder::Enemies, 1.0, 1.0) if @phase_dir == 1
        super()
        @darkness.draw(@x-@xsize+@phase, @y-@ysize-25+1, ZOrder::Enemies, 1.0, 1.0) if @phase_dir == -1
        if full then
            @halo.draw(@x-400, @y-@ysize-400, ZOrder::Enemies)
        end
    end
    
    def full
        return @phase_dir == 1
    end
    
    def custom_mechanics
        @phase += 0.1*@phase_dir
        if @phase >= 2*25 then
            @phase_dir = -1
        elsif @phase <= -2*25 then
            @phase_dir = 1
        end
    end
    
end
