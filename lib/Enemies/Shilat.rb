class Shilat < Enemy
    
    def activation
        @hp = 5
        @strength = (Difficulty.get > Difficulty::NORMAL ? 3 : 2)
        @score = 5000
        @world = 2
        @xsize = 50
        load_graphic("Shilat")
        @description = "Stronger and wider Shi.
        Somehow reminiscent of a pancake.
        Found in forests and parks."
    end
    
end
