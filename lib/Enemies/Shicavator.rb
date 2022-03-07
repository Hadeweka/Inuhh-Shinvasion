class Shicavator < Enemy
    
    def activation
        @speed = 1
        @world = 3
        @strength = (Difficulty.get > Difficulty::HARD ? 3 : 2)
        @score = 5000
        @hp = 3
        @reduction = 1
        @abyss_turn = false
        load_graphic("Shicavator")
        @description = "Hungry Shi which can eat nearly everything.
        Still not very strong and fast.
        Found in the Park Avenue."
    end
    
    def would_fit(offs_x, offs_y)
        return true if @through
        # Check at the center/top and center/bottom for map collisions
        expr = true
        0.upto((@ysize/25).floor) do |t|
            ((-@xsize/50)+1).floor.upto((@xsize/50).floor) do |u|
                edge_y = t == 0 ? 0 : 1
                edge_x = 0
                rx = @x + offs_x - (@xsize>25 ? 25 : 0) + u*50 - edge_x
                ry = @y + offs_y - 50*(t) + edge_y
                expr &&= !@map.solid?(rx + 25, ry)
                expr &&= !@map.solid?(rx - 24, ry)
                if @dir == :left && @map.solid?(rx, @y) && !@map.invalid(rx, @y) then
                    @window.add_tile(rx, @y, nil)
                    @window.play_sound("nom", 1, 1.0)
                end
                if @dir == :right && @map.solid?(rx+1, @y) && !@map.invalid(rx+1, @y)
                    @window.add_tile(rx+1, @y, nil)
                    @window.play_sound("nom", 1, 1.0)
                end
            end
        end
        return expr
    end
    
end
