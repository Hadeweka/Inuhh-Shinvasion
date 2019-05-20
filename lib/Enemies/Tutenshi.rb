class Tutenshi < Enemy
    
    def activation
        @score = 0
        @world = 6
        @defense = 5
        @hp = 13
        @bulletproof = true
        @strength = 8
        @speed = 3
        @hunting = true
        @projectile_type = Projectiles::Fire
        @border_jump_delay = 1
        @abyss_jump_delay = 1
        @random_jump_delay = 400 if Difficulty.get > Difficulty::NORMAL
        load_graphic("Tutenshi")
        @description = "T"
    end
    
    def at_shot(projectile)
        if projectile.type == Projectiles::Fire then
            detonate
            @window.spawn_enemy(Enemies::Shirath, @x, @y - 25, @dir)
        end
    end
    
    def at_death
        if @map.lethal(@x, @y) && @map.water(@x, @y) then	# Must be lava
            detonate
            @window.spawn_enemy(Enemies::Shirath, @x, @y - 25, @dir)
        end
    end
    
end
