class Shi_52 < Enemy
    
    def activation
        @score = 19000
        @world = 5
        @hp = 10
        @defense = 2
        @speed = 1
        @strength = 6
        @spike = true
        @spike_strength = 6
        @hunting = true
        @dodge_range = 0.1
        @gravity = false
        @abyss_turn = false
        @jump_image = false
        @anim_delay = 30
        @count_projectile = 0
        @projectile = true
        @projectile_reload = 13
        @border_turn = false
        #@no_knockback = true
        @ammo = (Difficulty.get > Difficulty::HARD ? 7 : 5)
        @ammo_reload = (Difficulty.get > Difficulty::NORMAL ? 151 : 201)
        @projectile_damage = 10
        @projectile_type = Projectiles::Fire
        @projectile_mechanics = [0.0, 20.0, 0.0, 0.0]
        @projectile_offset = [-@xsize, @ysize]
        @air_control = true
        load_graphic("Shi_52")
        @description = "A stronger Shicopter, now working as a bomber.
        Follows targets to launch fireballs at them.
        Aerial unit of the Shi Districts."
    end
    
    def custom_mechanics
        if @count_projectile == 0 then
            @projectile = true
        elsif @count_projectile <= -@projectile_reload*@ammo-1 then
            @projectile = false
            @count_projectile = @ammo_reload
        end
        @count_projectile -= 1
    end
    
end
