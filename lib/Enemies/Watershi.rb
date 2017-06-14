class Watershi < Enemy # Shi on... ski
    
    def activation
        @hp = 1
        @score = 4000
        @waterproof = true
        @speed = 1
        @abyss_turn = false
        @border_turn = true
        @world = 1
        @random_jump_delay = (Difficulty.get > Difficulty::EASY ? 1000 : nil)
        @border_jump_delay = 2
        load_graphic("Watershi")
        @description = "Normally slow Shi on motor driven surfboard. When surfing
        on water it can reach abnormal speeds. Can also do some
        sudden jumps to reach higher places.
        Mostly found at lakes and sometimes in underwater caves."
    end
    
    def would_fit(offs_x, offs_y)
        expr = super(offs_x, offs_y)
        0.upto((@ysize/25).floor) do |t|
            (-@xsize/50+1).floor.upto((@xsize/50).floor) do |u|
                edge_y = t == 0 ? 0 : 1
                edge_x = 0
                expr &&= !@map.water(@x + offs_x + 25 - (@xsize>25 ? 25 : 0) + u*50 - edge_x, @y + offs_y - 50*(t) + edge_y)
                expr &&= !@map.water(@x + offs_x - 24 - (@xsize>25 ? 25 : 0) + u*50 - edge_x, @y + offs_y - 50*(t) + edge_y)
            end
        end
        return expr
    end
    
    def move_mechanics
        super
        @speed = (Difficulty.get > Difficulty::NORMAL ? 10 : 7) if @map.water(@x - @xsize + 1, @y + 1) || @map.water(@x + @xsize - 1, @y + 1)
        @speed = (Difficulty.get > Difficulty::HARD ? 3 : 1) if @map.solid?(@x - @xsize + 1, @y + 1) || @map.solid?(@x + @xsize - 1, @y + 1)
    end
    
    def try_to_jump
        if @map.solid?(@x - @xsize + 1, @y + 1) || @map.solid?(@x + @xsize - 1, @y + 1) then
            @vy = -15
            @jumping = true
            @window.play_sound("jump") if !@air_control && would_fit(0, -1) && (@inuhh.x - @x).abs <= 320 && (@inuhh.y - @y).abs < 240
        elsif  @map.water(@x - @xsize + 1, @y + 1) || @map.water(@x + @xsize - 1, @y + 1) then
            @vy = -20
            @jumping = true
            @window.play_sound("jump") if !@air_control && would_fit(0, -1) && (@inuhh.x - @x).abs <= 320 && (@inuhh.y - @y).abs < 240
        end
    end
    
end
