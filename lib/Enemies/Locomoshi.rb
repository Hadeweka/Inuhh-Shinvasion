class Locomoshi < Enemy
    
    def activation
        @hp = 12
        @strength = 7
        @defense = 5
        @speed = 10
        @range = 100000
        @abyss_turn = false
        @border_turn = true
        @ysize = 50
        @score = 21000
        @world = 6
        load_graphic("Locomoshi")
        @description = "T"
    end
    
    def custom_mechanics
        @dangerous = !(@inuhh.riding_entity.is_a?(Carriashi) && @inuhh.riding_entity.param == @param)
    end
    
end
