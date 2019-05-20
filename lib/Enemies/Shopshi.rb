class Shopshi < Enemy
    
    def activation
        @speed = 2
        @strength = 0
        @defense = 0
        @hp = 15
        @drop = nil
        @price = 0
        @score = 9000
        @world = 6
        @mindamage = 0
        load_graphic("Shopshi")
        @description = "T"
    end
    
    def custom_mechanics
        @speed = [0, 1, 2, 3, 4].sample if rand(50) == 0
        arr = [*([[Objects::Gem, 20]]*2), *([[Objects::Bone, 5]]*5), *([[Objects::Fruit, 1]]*20), *([[Objects::Gold_Bone, 30]]*1)].sample
        @drop = arr[0]
        @price = arr[1]
    end
    
    def at_collision
        if rand((Difficulty.get > Difficulty::NORMAL ? 3 : 6)) == 0 then
            arr = [*([[Enemies::Shinamite, 10]]*3), *([[Enemies::TNShi, 5]]*5), *([[Enemies::Extashi, 1]]*10), *([[Enemies::Chishi, 3]]*20), *([[Enemies::Shopshi, 20]]*1)].sample
            e_enemy = arr[0]
            e_price = arr[1]
            if @inuhh.collectibles[Objects::Coin] >= e_price then
                @inuhh.steal_coins(e_price)
                @window.spawn_enemy(e_enemy, @x, @y - @ysize - 100, @dir)
            end
        else
            if @inuhh.collectibles[Objects::Coin] >= @price then
                @inuhh.steal_coins(@price)
                @window.gems.push(Object_Datas::C_Index[@drop].new(@window.valimgs[@drop], (@x/50).floor * 50 + 25, (@y/50).floor * 50 + 50 - 100))
            end
        end
    end
    
end
