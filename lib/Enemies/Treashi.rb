class Treashi < Enemy
    
    def activation
        @speed = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
        @score = 2000
        @world = 5
        @drop = Objects::Key
        load_graphic("Treashi")
        @description = "This Shi looks like a regular Chishi but
        drops a key if smashed Distinguishable because
        for some reason it is slightly allergic to keys.
        Lives in the Shi Districts near Chishis."
    end

end
