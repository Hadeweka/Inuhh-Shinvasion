class Shinertia < Enemy
    
    def activation
        @speed = (Difficulty.get > Difficulty::NORMAL ? 3 : 2)
        @score = 11000
        @defense = 0
        @world = 6
        @hp = 10
        @strength = 3
        @shindulum = @window.spawn_enemy(Enemies::Shindulum, @x, @y-@ysize+25, @dir, 1) if !EDITOR && !SHIPEDIA
        @shindulum.bind(self) if !EDITOR && !SHIPEDIA
        load_graphic("Shinertia")
        @description = "T"
    end
    
    def at_death
        @shindulum.detonate if @shindulum
        super()
    end
    
end
