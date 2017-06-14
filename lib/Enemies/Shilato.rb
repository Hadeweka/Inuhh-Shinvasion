class Shilato < Enemy
    
    def activation
        @hp = 10
        @strength = 4
        @reduction = 1
        @defense = 0
        @range = 400
        @score = 12000
        @speed = 5
        @ysize = 50
        @world = 4
        @border_turn = true
        @abyss_turn = false
        @gravity = false
        @waterproof = true
        load_graphic("Shilato")
        @description = "A Neshi-like swimming Shi with high speed,
        health and strength.
        For some reason it looks like ice cream.
        Rare Shi variant found on some colder seas."
    end
    
    def move_mechanics
        super
        if @hp <= 5 && rand(5*@hp) == 0 && Difficulty.get > Difficulty::NORMAL then
            @speed += rand(2)*2-1
            @speed = [[@speed, 3].max, (Difficulty.get == Difficulty::DOOM ? 9 : 7)].min
        end
    end
    
end
