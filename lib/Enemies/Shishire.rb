class Shishire < Enemy
    
    def activation
        @z = 100
        @speed = 0
        @score = 9000
        @cloaked = true
        @moving = false
        @gravity = false
        @waterproof = true
        @invisible = true if SHIPEDIA
        @world = 5
        @strength = (Difficulty.get > Difficulty::NORMAL ? 7 : 6)
        load_graphic("Shishire")
        @description = "Rare variant of the Kamigasshi. Will shoot
        out to the front if someone comes along,
        too, but is much stronger and also faster.
        Has a gruesome smile due to priority in its
        development on speeds and not its look.
        Lives hidden on the Shi Trail."
    end

    def draw
        if SHIPEDIA || EDITOR || !@cloaked then
            super
        else
            @cur_image = @map.tileset[Tiles::Small_Grass]
            @cur_image.draw(@x - 5 - @x%50, @y - @ysize*2 + 50 - 5 - @y%50, ZOrder::Foreground, 1.0, 1.0, 0x44ffffff)
        end
    end
    
    def z_mechanics
        if @vz == 0 then
            if ((@x-@inuhh.x).to_f/(40).to_f)**2 + ((@y-@inuhh.y-1+25).to_f/(25).to_f)**2 < 1 then
                @vz = -12
                @cloaked = false
            end
        else
            @vz -= 1.0+(@vz)/10
        end
        if @vz > 0 then
            @vz.floor.times { @z += 1 }
        end
        if @vz < 0 then
            (-@vz).floor.times { @z -= 1 }
        end
        @z = [100, @z].min
        @living = false if @z < -200
    end
    
    
end
