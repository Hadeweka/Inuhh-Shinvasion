class Quanshi < Enemy
    
    def activation
        @world = 3
        @strength = 3
        @speed = 4
        @hp = 5
        @score = 8000
        load_graphic("Quanshi")
        @description = "This Shi follows the uncertanity principle
        of quantum mechanics, so its location can
        vary strongly. Also can tunnel through walls
        because of this.
        Lives in dark and unknown places."
    end
    
    def custom_mechanics
        if Difficulty.get > Difficulty::NORMAL then
            xadd = rand(25)-12
            yadd = rand(25)-12
        else
            xadd = rand(17)-8
            yadd = rand(17)-8
        end
        extra = true if rand(10) == 0
        if extra then
            xadd *= 10 if rand(2) == 0
            yadd *= 10 if rand(2) == 0
        end
        if would_fit(xadd, 0) then
            @x += xadd
        end
        if would_fit(0, yadd) then
            @y += yadd
        end
    end
    
end
