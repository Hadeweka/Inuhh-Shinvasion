class Pacshi < Enemy
    
    def activation
        @speed = 3
        @score = 14000
        @world = 5
        @hp = 10
        @strength = (Difficulty.get > Difficulty::NORMAL ? 6 : 5)
        @defense = 2
        @food = false
        @saturation = 0
        load_graphic("Pacshi")
        @description = "Weird Shi which is reminiscent of
        something. If it gets hungry it will
        eat wooden blocks, but spits them out
        very soon then, sometimes on enemies to
        kill them instantly.
        'Works' in the Shi Factory."
    end
    
    def custom_mechanics
        x_map_index = @x + (@dir == :left ? -1 : 1)*(@xsize+5)
        if !@food && @saturation <= 0 && @map.type(x_map_index, @y) == Tiles::Exterior && !@map.invalid(x_map_index, @y) then
            @food = true
            @saturation = 200+rand(200)
            @window.play_sound("nom", 1, 0.6)
            @window.add_tile(x_map_index, @y, nil)
        elsif @food then
            x_map_index_new = @x + (@dir == :left ? -1 : 1)*(@xsize+50)
            if rand(150) == 0 && !@map.type(x_map_index_new, @y)  && !@map.invalid(x_map_index_new, @y) then
                @food = false
                @window.add_tile(x_map_index_new, @y, Tiles::Exterior)
                @window.play_sound("plop", 1, 1.4)
            end
        end
        @strength = (@food ? 1 : (Difficulty.get > Difficulty::NORMAL ? 6 : 5))
        @cur_image = @walk2 if @food || @saturation > 0
        @saturation -= 1 if !@food
    end
    
end
