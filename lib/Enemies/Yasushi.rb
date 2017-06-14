class Yasushi < Enemy
    
    def activation
        @hp = 2
        @score = 4000
        @speed = 1
        @havoc = true
        @world = 1
        load_graphic("Yasushi")
        @description = "A Shi out of control running around in irregular
        patterns, often turning around.
        Probably a failed attempt of genetical engineering.
        Found often next to Takashis."
    end
    
    def move_mechanics
        super
        if rand(10*@hp*@hp*@hp) == 0 then
            @speed += rand(2)*2-1
            @speed = [[@speed, 1].max, (Difficulty.get > Difficulty::NORMAL ? 4 : 1)].min
        end
        if rand(10*@hp*@hp*@hp) == 0 then
            @dir = (@dir == :left ? :right : :left)
        end
    end
    
end
