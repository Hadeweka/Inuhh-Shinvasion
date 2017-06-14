class Shitar < Enemy
    
    def activation
        @world = 3
        @xsize = 50
        @ysize = 50
        @strength = 10
        @spike_strength = 10
        @spike = true
        @score = 17000
        @defense = 1
        @abyss_turn = false
        @air_control = true
        @gravity = false
        @speed = 1
        @hp = 5
        @havoc = true
        @projectile_damage = 1000
        @projectile_type = Projectiles::Doom
        @projectile_owner = Projectiles::RAMPAGE
        @detonation_intensity = 200
        @detonation_speed = 10
        @detonation_acc = -0.1
        @gravity_detonation = 0.0
        @range = 100000
        load_graphic("Shitar")
        @description = "Powerful and big Shi with a hot shell,
        albeit very slow. Normally it holds its
        enormous energy in its body, but projectiles
        can bring it to explode and destroy everything.
        Likes to live in hot, but dark areas."
    end
    
    def fuse_mechanics
        @shading -= 0x00000101 if @fuse_counter
        if @fuse_counter then
            xadd = rand(45)-22
            yadd = rand(45)-22
            if would_fit(xadd, 0) then
                @x += xadd
            end
            if would_fit(0, yadd) then
                @y += yadd
            end
        end
        super()
    end
    
    def at_shot(projectile)
        @defense = 1000
        fuse
        super(projectile)
    end
    
end
