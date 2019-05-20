class Illushi < Enemy
    
    def activation
        @speed = 0
        @invisible = true
        @moving = false
        @gravity = false
        @waterproof = true
        @score = 4000
        @xsize = 100
        @ysize = 100
        @world = 1
        @strength = 3
        @mindamage = 1
        @spike = true
        @spike_strength = 3
        @minsdamage = 1
        @defense = 5
        @hp = 10
        @scare_counter = 0
        load_graphic("Illushi")
        @description = "T"
    end
    
    def at_collision
        @invisible = false
        @window.play_sound("scream", 1.0, 0.5+rand)
        @scare_counter = 50
    end
    
    def custom_mechanics
        @scare_counter -= 1 if @scare_counter > 0
        if @scare_counter == 0 then
            @invisible = true
        end
    end
    
end
