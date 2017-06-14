class Erupshi < Enemy
    
    def activation
        @score = 17000
        @hp = 10
        @strength = (Difficulty.get > Difficulty::NORMAL ? 6 : 5)
        @defense = 3
        @speed = 1
        @cycle = 0
        @world = 4
        @xsize = 100
        @ysize = 100
        @spike = true
        @spike_strength = (Difficulty.get > Difficulty::NORMAL ? 6 : 5)
        load_graphic("Erupshi")
        @description = "Giant and bulky Shi with a hot head.
        It spits out Ignishis periodically out
        of its head, which explode by crashing
        into walls. May also lag the game a bit.
        Lives in the Inferno Core."
    end
    
    def custom_mechanics
        @cycle += 1
        if @cycle == 500 then
            @speed = 0
        end
        if @cycle > 500 then
            @x += @cycle % 3 - 1
        end
        if @cycle >= 600 && @cycle % 50 == 0 then
            if @cycle == 900 then
                @cycle = 0
                @speed = 1
            end
            en = @window.spawn_enemy(Enemies::Shignite, @x, @y-2*@ysize, [:left, :right].sample)
            en.force_jump(10+rand(15))
            en.fuse
            en.crash_detonation = true
        end
    end
    
end
