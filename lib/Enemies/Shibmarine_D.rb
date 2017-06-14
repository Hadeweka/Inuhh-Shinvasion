class Shibmarine_D < Enemy # Z-variable Shibmarine
    
    def activation
        @z = 100
        @moving = false
        @gravity = false
        @waterproof = true
        @score = 3000
        @z_dir = 1
        @speed = 0
        @world = 1
        load_graphic("Shibmarine_D")
        @description = "Special Shibmarine capable of using the third
        dimension. Only dangerous if too close to Inuhh.
        Found in every possible water landscape."
    end
    
    def z_mechanics
        @z_dir = -@z_dir if @z.abs >= 100
        @vz = @z_dir*(Difficulty.get > Difficulty::NORMAL ? 2 : 1)
        super
    end
    
end
