class Shitraw < Enemy
    
    def activation
        @score = 7000
        @spike = true
        @spike_strength = (Difficulty.get > Difficulty::EASY ? 3 : 2)
        @strength = 3
        @world = 3
        @criminal = true # Nobody said the Shi were fair
        @random_jump_delay = 500 if Difficulty.get > Difficulty::NORMAL
        @hp = 3
        @speed = 3
        load_graphic("Shitraw")
        @description = "Feral Shi member used as slave.
        Not that strong but very fast. Has spikes.
        It was blinded slightly because it must not
        see the wealth of the Shitizens.
        Lives near Pondton City."
    end
    
end
