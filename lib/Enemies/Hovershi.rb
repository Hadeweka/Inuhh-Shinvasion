class Hovershi < Enemy
    
    def activation
        @score = 16000
        @speed = 1
        @defense = (Difficulty.get > Difficulty::EASY ? 2 : 1)
        @hp = 5
        @dodge_range = 0.02
        @world = 5
        @strength = 7
        @gravity = false
        @hunting = true
        @waterproof = true
        @border_turn = false
        @abyss_turn = false
        @jump_image = false
        @air_control = true
        load_graphic("Hovershi")
        @description = "One of the most unfair Shi units. Using
        its hovercraft-like engine it can achieve
        very high speeds. Also it can dodge attacks
        very well. Extremely dangerous!
        Uncommon unit of the Shi Districts."
    end
    
    def move_mechanics
        super
        if @inuhh.y == @y then
            @vy = 0
            @speed = 10
            @dodge_range = 0.02
        else
            if @inuhh.y < @y then
                @vy = -5
                @speed = 10
                @dodge_range = 3
            else
                @speed = 1
                @dodge_range = 0.02
                @vy = 5
            end
        end
        
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
    
end
