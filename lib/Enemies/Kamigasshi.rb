class Kamigasshi < Enemy # Invisible Shi, suddenly attacking you
    
    def activation
        @z = 100
        @speed = 0
        @cloaked = true
        @moving = false
        @gravity = false
        @waterproof = true
        @invisible = true if SHIPEDIA
        @score = 4000
        @world = 1
        @strength = (Difficulty.get > Difficulty::NORMAL ? 2 : 1)
        load_graphic("Kamigasshi")
        @description = "Hidden ninja unit of the Shi Empire. Can appear
        without warning and accelerate forward.
        Very rare, but can be found mostly in great number."
    end

    def draw
        if SHIPEDIA || EDITOR || !@cloaked then
            super
        else
            @cur_image = @map.tileset[Tiles::Small_Grass]
            @cur_image.draw(@x - 5 - @x%50, @y - @ysize*2 + 50 - 5 - @y%50, ZOrder::Foreground, 1.0, 1.0, 0x33ffffff)
        end
    end
    
    def z_mechanics
        if @vz == 0 then
            if ((@x-@inuhh.x).to_f/(40).to_f)**2 + ((@y-@inuhh.y-1+25).to_f/(25).to_f)**2 < 1 then
                @vz = -10
                @cloaked = false
            end
        else
            @vz -= 1.0+(@vz)/10
        end
        super
    end
    
end
