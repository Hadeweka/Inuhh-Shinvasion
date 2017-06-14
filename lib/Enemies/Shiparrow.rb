class Shiparrow < Enemy
    
    def activation
        @score = 4000
        @world = 2
        @speed = 3
        @strength = (Difficulty.get > Difficulty::HARD ? 2 : 1)
        @gravity = false
        @abyss_turn = false
        @jump_image = false
        @air_control = true
        @description = "This flying Shi is not very strong, but can
        easily kick someone around.
        It is found in big number in forests."
        load_graphic("Shiparrow")
    end
    
    def move_mechanics
        super
        @vy = (Math::cos(@tics/63.0*1000.0/100.0)*3).to_i
    end
    
end
