class Invinshi < Enemy
    
    def activation
        @defense = 1000
        @speed = 3
        @world = 2
        @score = 0
        load_graphic("Invinshi")
        @description = "Invincible, but otherwise weak Shi.
        Hard to create, however, so it is quite rare.
        One of the places to find it is the Dominwood Forest."
    end
    
end
