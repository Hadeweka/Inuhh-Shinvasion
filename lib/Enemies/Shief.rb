class Shief < Enemy
    
    def activation
        @score = 0
        @strength = 1
        @speed = 4
        @hp = 3
        @score = 6000
        @world = 3
        @hunting = true
        @inventory = 0
        @criminal = true
        @border_turn = false
        @abyss_turn = false
        @abyss_jump_delay = 1
        @border_jump_delay = 1
        load_graphic("Shief")
        @description = "A world without thiefes is just impossible.
        Thus the Shi Empire sent some of them to
        steal unaware dogs there money.
        Mainly found on Westton Mountain."
    end
    
    def at_collision
        @inventory += @inuhh.steal_coins((Difficulty.get > Difficulty::EASY ? 30 : 20))
        if @inventory > 0 then
            @fleeing = true
            @dodge_range = 0.1
            @speed = 6
            @drop_count = @inventory
            @drop = Objects::Coin
        end
    end
    
end
