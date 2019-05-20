class Shinny < Enemy
    
    def activation
        @ysize = 50
        @world = 6
        @strength = 12
        @score = 22000
        @speed = 5
        @defense = 0
        @hp = 17
        @hunting = true
        @waterproof = true
        @abyss_turn = false
        @jump_image = false
        @air_control = true
        @gravity = false
        @entity = nil
        @through = true
        load_graphic("Shinny")
        @description = "T"
    end
    
    def custom_mechanics
        if @entity then
            if (@entity != @inuhh && @entity.hp <= 0) then
                detonate
            end
            if @entity != @inuhh then
                @hunting = true
                @vy = 0
                @vy = @speed if @inuhh.y > @y
                @vy = -@speed if @inuhh.y < @y
            else
                @hunting = false
                @reduction = 1
                @mindamage = 0
                @moving = false
                @strength = 0
            end
            if (@x - @entity.x)**2 + (@y - @entity.y)**2 >= 300*300 then
                @x = @entity.x
                @y = @entity.y - 100
                @window.play_sound("warp", 1, 0.8 + 0.4*rand)
            end
        else
            
        end
    end
    
    def bind(entity)
        @entity = entity
    end
    
    def try_to_jump
        
    end
    
end
