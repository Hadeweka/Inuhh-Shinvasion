class Hyashi < Enemy
    
    def activation
        @score = 11000
        @speed = 1
        @waterscore = 0
        @hp = 7
        @maxhp = 7
        @strength = (Difficulty.get > Difficulty::EASY ? 7 : 5)
        @max_waterscore = 500 + rand(1000)
        @world = 5
        @no_inv = false
        @waterproof = true
        @transformed = false
        load_graphic("Hyashi")
        @description = "Beautiful Shi with a flower head but also
        with an unexpected strength. Gets healed
        if hit by much water and can also grow
        if watered enough at full health.
        Lives in the Shi Sanatorium and nearby areas."
    end
    
    def flowerful
        return true if @waterscore >= @max_waterscore-1 && (@hp == @maxhp || @transformed)
    end
    
    def at_shot(projectile)
        if projectile.type == Projectiles::Water then
            @sound_on = false
            @waterscore += 1
            @no_inv = true
            if @waterscore % 150 == 0 && @hp < @maxhp && @hp > 0 then
                @window.messages.push(["+ 1", @x, @y+@ysize, 100, true, 2.0, 2.0, 0xff8800ff])
                @hp += 1
                @waterscore -= 150
            end
        end
        super(projectile)
    end
            
    def custom_mechanics
        @invul = 0 if @no_inv
        @no_inv = false
        if @waterscore >= @max_waterscore && @hp == @maxhp then
            @window.spawn_enemy(Enemies::Shidacea, @x, @y, @dir)
            @transformed = true
            damage(1000)
        end
    end
            
end
