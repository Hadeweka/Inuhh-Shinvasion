class Shiturn < Enemy
    
    def activation
        @strength = 3
        @score = 9000
        @world = 2
        @speed = 2
        @hp = (Difficulty.get > Difficulty::HARD ? 7 : 10)
        @reduction = 1
        @abyss_turn = false
        load_graphic("Shiturn")
        @description = "A Shi member, even more stupid than a Daishi.
        Can be controlled by jumping on its head.
        Also can cause eye cancer.
        Found only in dangerous areas because of its incompetence."
    end
    
    def damage(value)
        super
        switch_dir
    end
    
end
