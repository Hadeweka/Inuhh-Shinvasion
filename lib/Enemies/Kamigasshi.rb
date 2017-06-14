class Kamigasshi < Enemy # Invisible Shi, suddenly attacking you
    
    def activation
        @z = 100
        @speed = 0
        @invisible = true
        @moving = false
        @gravity = false
        @waterproof = true
        @score = 4000
        @world = 1
        @strength = (Difficulty.get > Difficulty::NORMAL ? 2 : 1)
        load_graphic("Kamigasshi")
        @description = "Hidden ninja unit of the Shi Empire. Can appear
        without warning and accelerate forward.
        Very rare, but can be found mostly in great number."
    end
    
    def z_mechanics
        if @vz == 0 then
            if ((@x-@inuhh.x).to_f/(40).to_f)**2 + ((@y-@inuhh.y-1+25).to_f/(25).to_f)**2 < 1 then
                @vz = -10
                @invisible = false
            end
        else
            @vz -= 1.0+(@vz)/10
        end
        super
    end
    
end
