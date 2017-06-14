class Shimmy < Enemy
    
    def activation
        @score = 8000
        @world = 3
        @hp = 3
        @strength = 5
        @speed = 1
        @hunting = true
        @border_turn = false
        @abyss_turn = false
        @border_jump_delay = 1
        @abyss_jump_delay = 1
        @random_jump_delay = 400 if Difficulty.get > Difficulty::NORMAL
        load_graphic("Shimmy")
        @description = "A mummyfied Shi with relatively high strength.
        It tries to hunt its prey, but it's very slow.
        It can be found mostly in the Temple of Dyunteh."
    end
    
end
