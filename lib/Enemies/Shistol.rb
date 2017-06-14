class Shistol < Enemy
    
    def activation
        @strength = 1
        @defense = 1
        @world = 1
        @speed = (Difficulty.get == Difficulty::DOOM ? 2 : 1)
        @score = 4000
        diff_hash = {Difficulty::EASY => nil, Difficulty::NORMAL => 1000, Difficulty::HARD => 200, Difficulty::DOOM => 50}
        @random_jump_delay = Difficulty.get > Difficulty::HARD ? 1000 : nil
        @border_jump_delay = (Difficulty.get > Difficulty::EASY ? 5 : nil)
        @abyss_jump_delay = nil
        @projectile = true
        @projectile_reload = (Difficulty.get > Difficulty::NORMAL ? 71 : 103)
        @projectile_damage = 2
        @projectile_offset = [0.0, -@ysize+3.0]
        @projectile_mechanics = [1.0, 0.0, 0.0, 0.0]
        @drop = Objects::Shistol if rand(5) == 0 || SHIPEDIA || @param == 1
        load_graphic("Shistol")
        @description = "This Shi carries a pistol and shoots without aiming.
        It is not a big friend of sunny areas, because the pistol
        helmet heats up its body too much."
    end
    
end
