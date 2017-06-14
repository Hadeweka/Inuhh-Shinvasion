class Sushi < Enemy
    
    def activation
        @score = 4000
        @speed = 1
        @world = 1
        @strength = (Difficulty.get > Difficulty::NORMAL ? 3 : 2)
        @gravity = false
        @waterproof = true
        @abyss_turn = false
        load_graphic("Sushi")
        @description = "Marine Shi with fin, but very slow.
        Can inflict some serious damage and can't hold
        a specific swimming speed, so it is hard to predict.
        Found in more unknown lakes because of its
        delicious taste."
    end
    
    def move_mechanics
        super
        if rand(Difficulty.get > Difficulty::NORMAL ? 30 : 50)==0 then
            @speed += rand(2)*2-1
            @speed = [[@speed, 0].max, (Difficulty.get > Difficulty::HARD ? 3 : 2)].min
        end
    end
    
end
