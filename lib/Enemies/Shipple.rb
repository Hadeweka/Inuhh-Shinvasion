class Shipple < Enemy
    
    def activation
        @speed = 0
        @hp = 3
        @defense = 0
        @score = 4000
        @world = 2
        @range = 200
        @moving = false
        @gravity = false
        @dir_set = true
        @strength = (Difficulty.get > Difficulty::NORMAL ? 2 : 1)
        load_graphic("Shipple")
        @speed = 2 if SHIPEDIA
        @gravity = true if SHIPEDIA
        @description = "This Shi is proud of its not too bad
        camouflage, but it forgot to cover its eyes.
        Still can be overlooked easily if not careful.
        Found in forests of each kind."
    end
    
    def custom_mechanics
        if (@inuhh.x - @x).abs < 50 && (1..100) === (@inuhh.y - @y)  && !@moving then
            @speed = 2
            @moving = true
            @gravity = true
        end
    end
    
end
