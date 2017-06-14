class Pushi < Enemy
    
    def activation
        @speed = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
        @score = 7000
        @strength = 2
        @defense = 1
        @hp = 4
        @world = 2
        @knockback = 20
        load_graphic("Pushi")
        @description = "This Shi owns a special shield to knock back
        enemies. It forgot to put a shield on his head, though.
        Can be found in many places."
    end
    
end
