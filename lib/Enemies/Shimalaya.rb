class Shimalaya < Enemy
    
    def activation
        @hp = 3
        @speed = 1
        @strength = 3
        @score = 5000
        @world = 3
        load_graphic("Shimalaya")
        @description = "Shivering Shi variant. Stronger and tougher
        than normal Chishis, but still not very fast.
        Lives (involuntary) in cold regions."
    end
    
    def custom_mechanics
        if Difficulty.get > Difficulty::NORMAL then
            xadd = rand(13)-6
        else
            xadd = rand(7)-3
        end
        if would_fit(xadd, 0) then
            @x += xadd
        end
    end
    
end
