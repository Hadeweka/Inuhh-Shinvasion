class Carriashi < Enemy
    
    def activation
        @hp = 10
        @strength = 5
        @defense = 6
        @speed = 10
        @range = 100000
        @abyss_turn = false
        @border_turn = true
        @score = 19000
        @riding = true
        @world = 6
        load_graphic("Carriashi")
        @description = "T"
    end
    
    def custom_mechanics
        @dangerous = !(@inuhh.riding_entity.is_a?(Carriashi) && @inuhh.riding_entity.param == @param)
    end
    
end
