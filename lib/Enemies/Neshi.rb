class Neshi < Enemy # First boss
    
    def activation
        @boss = true
        @hp = 20
        @maxhp = @hp
        @score = 52000
        @speed = 4
        @ysize = 50
        @range = 100
        @world = 1
        @reduction = 1
        @mindamage = 1
        @border_turn = true
        @abyss_turn = false
        @gravity = false
        @waterproof = true
        @drop = Objects::Wing
        load_graphic("Neshi")
        @description = "Shi entity with extreme health and high speed properties.
        Can behave unpredictable if endangered. Also guarded
        by Shizookas and Gammarines to guarantee its security.
        Can only be found at a hidden place of the Cleanbuil Lake."
    end
    
    def move_mechanics
        super
        if @hp <= 10 && rand(5*@hp) == 0 && Difficulty.get > Difficulty::EASY then
            @speed += rand(2)*2-1
            @speed = [[@speed, 2].max, (Difficulty.get == Difficulty::DOOM ? 10 : 6)].min
        end
        if @hp <= 5 && rand(10*@hp) == 0 && Difficulty.get > Difficulty::NORMAL then
            @dir = (@dir == :left ? :right : :left)
        end
    end
    
end
