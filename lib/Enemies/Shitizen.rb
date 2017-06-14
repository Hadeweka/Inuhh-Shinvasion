class Shitizen < Enemy
    
    def activation
        @score = 7000
        @speed = 2
        @world = 3
        @strength = 2
        @defense = 0
        @hp = 6
        @ysize = 50
        @inventory = 6
        @random_jump_delay = 300 if Difficulty.get > Difficulty::NORMAL
        @drop_count = @inventory
        @drop = Objects::Coin
        load_graphic("Shitizen")
        @description = "Capitalistic Shi with high ego. Drops
        money if hurt. It is so vain it sometimes
        even breaks the fourth wall to admire its
        pretended beauty and fame in the camera reflection.
        Lives in Pondton City and some other buildings."
    end
    
    def custom_mechanics
        if rand(100) == 0 then
            @speed = (@speed = 2 ? (rand(7) == 0 ? 0 : 2) : 2)
        end
        if @inventory > 0 then
            @drop_count = @inventory
            @drop = Objects::Coin
        else
            @drop = nil
        end
    end
    
    def damage(value)
        super(value)
        @speed = 2
        @drop_count = [value,@inventory].min
        @inventory -= @drop_count
        @drop_count.times do
            xvar = (@drop_count > 1 ? 1 : 0)*(rand(20)-10)
            yvar = (@drop_count > 1 ? 1 : 0)*(rand(10))
            @window.gems.push(Object_Datas::C_Index[@drop].new(@window.valimgs[@drop], (@x/50).floor * 50 + 25 + xvar, (@y/50).floor * 50 + 50 - yvar))
        end
        @drop = nil if @inventory <= 0
    end
    
end
