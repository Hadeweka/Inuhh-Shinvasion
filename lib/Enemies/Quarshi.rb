class Quarshi < Enemy
    
    def activation
        @strength = (Difficulty.get > Difficulty::HARD ? 4 : 3)
        @world = 3
        @hp = 8
        @speed = 1
        @score = 0
        @drop = Objects::Sand
        @drop_count = 1
        @score = 8000
        load_graphic("Quarshi")
        @description = "A Shi very difficult to see. Not much stronger
        than some other Shi, but has some health.
        Doesn't survive projectiles, though, because
        the heat melts themselves into glass.
        Lives basically in the Sand Meadow."
    end
    
    def at_shot(projectile)
        damage(10)
        @drop = nil
        @drop_count = 0
        super(projectile)
    end
    
end
