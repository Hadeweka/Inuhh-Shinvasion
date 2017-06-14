class Multishi < Enemy
    
    def activation
        @score = 13000
        @world = 5
        @hp = 11
        @strength = 5
        @speed = (Difficulty.get > Difficulty::EASY ? 3 : 2)
        @multi_count = (@param ? @param : 2)
        @multi_counter = 0
        load_graphic("Multishi")
        @description = "Special Shi which can multiplicate if
        not destroyed fast enough.
        Found in some sections of the Shi Districts."
    end
    
    def change_speed(val)
        @speed = val
    end
    
    def custom_mechanics
        @multi_counter += 1
        if @multi_count > 0 && @multi_counter >= 300/@multi_count then
            new_e = @window.spawn_enemy(Enemies::Multishi, @x, @y, (@dir == :left ? :right : :left), @multi_count-1)
            new_e.change_speed(@speed+1)
            @multi_count -= 1
            @multi_counter = 0
        end
    end
    
end
