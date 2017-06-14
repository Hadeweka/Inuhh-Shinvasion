class Gattershi < Enemy
    
    def activation
        @score = 6000
        @waterproof = true
        @speed = 1
        @strength = 2
        @world = 2
        @hunting = true
        @abyss_turn = false
        @border_turn = true
        @random_jump_delay = (Difficulty.get > Difficulty::EASY ? 1000 : nil)
        @border_jump_delay = 2
        load_graphic("Gattershi")
        @description = "Stronger version of the Watershi, also hunting its prey.
        Found in darker lakes and sometimes even on lava."
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
        @speed = 5 if @map.water(@x - @xsize + 1, @y + 1) || @map.water(@x + @xsize - 1, @y + 1)
        @speed = 1 if @map.solid?(@x - @xsize + 1, @y + 1) || @map.solid?(@x + @xsize - 1, @y + 1)
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
