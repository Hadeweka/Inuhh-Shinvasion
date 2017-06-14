class Khashi < Enemy
    
    def activation
        @score = 7000
        @speed = 0
        @hp = 5
        @world = 2
        @maxhp = @hp
        @strength = 2
        @defense = 0
        @range = 200
        @knockback = 10
        @moving = false
        @gravity = false
        @dir_set = true
        @invisible = true if SHIPEDIA
        load_graphic("Khashi")
        @speed = 2 if SHIPEDIA
        @gravity = true if SHIPEDIA
        @description = "Another camouflage-using Shi. Hides (better than Shipples)
        inside leaves and kicks back everyone touching him.
        Found in forests, so being careful can save lifes."
    end
    
    def draw
        if SHIPEDIA || EDITOR || @hp < @maxhp then
            super
        else
            @cur_image = @map.tileset[Tiles::Tree]
            @cur_image.draw(@x - 5 - @x%50, @y - @ysize*2 + 50 - 5 - @y%50, ZOrder::Tiles)
        end
    end
    
    def custom_mechanics
        if @hp < @maxhp && !@moving then
            @speed = (Difficulty.get > Difficulty::HARD ? 3 : 2)
            @moving = true
            @gravity = true
        end
    end
    
end
