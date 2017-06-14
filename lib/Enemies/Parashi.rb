class Parashi < Enemy
    
    def activation
        @score = 0
        @world = 3
        @speed = (SHIPEDIA ? 3 : 0)
        @gravity = false
        @abyss_turn = false
        @jump_image = false
        @air_control = true
        @ysize = 50
        @score = 4000
        load_graphic("Parashi")
        @description = "Air unit of the Shi Empire. Uses a parachute
        to glide down and to become a normal Chishi
    when touching ground. Sometimes sails into death,
        since the parachute only triggers while landing.
        Found inside and outside the Westton Mountain."
        
    end
    
    def move_mechanics
        @vy = 1
        @vx = (Math::cos(@tics/63.0*1000.0/500.0)*30.0/5.0)
        super
    end
    
    def custom_mechanics
        if !would_fit(0, 1) then
            @window.spawn_enemy(Enemies::Chishi, @x, @y, @dir)
            damage(1000)
        end
    end
    
end
