class Wereshi < Enemy
    
    def activation
        @score = 19000
        @strength = 9
        @speed = (Difficulty.get == Difficulty::DOOM ? 7 : 6)
        @defense = 2
        @hp = 10
        @world = 5
        @hunting = true
        @border_turn = false
        @border_jump_delay = 10
        @abyss_jump_delay = 3
        @abyss_turn = false
        @jump_speed = -20
        diff_hash = {Difficulty::EASY => nil, Difficulty::NORMAL => 1000, Difficulty::HARD => 200, Difficulty::DOOM => 50}
        @random_jump_delay = diff_hash[Difficulty.get]
        @border_jump_delay = (Difficulty.get > Difficulty::EASY ? 20 : nil)
        @abyss_jump_delay = (Difficulty.get > Difficulty::EASY ? 20 : nil)
        load_graphic((SHIPEDIA || EDITOR ? "Wereshi" : "Chishi"))
        @description = "A normal Chishi with a broken gene so it turned
        into a monster Shi in the light of a Lunarshi.
        Has abnorm strength and health and will chase
        enemies until not touched by the light anymore.
        Then it will turn back into a normal Chishi.
        Only seems to reside on the Shi Trail, but who knows?"
    end
    
    def pre_custom_mechanics
        true_form = false
        @window.enemies.each do |e|
            true_form = true if (e.is_a? Lunarshi) && e.full && (@x-e.x)**2+(@y-e.y)**2 <= 400*400
        end
        if true_form then
            load_graphic("Wereshi") if @loaded_graphic == "Chishi"
            @score = 19000
            @strength = 9
            @speed = (Difficulty.get == Difficulty::DOOM ? 7 : 6)
            @defense = 2
            @hp = 10
            @hunting = true
            @border_turn = false
            @border_jump_delay = 10
            @abyss_jump_delay = 3
            @jump_speed = -20
            @abyss_turn = false
        else
            load_graphic("Chishi") if @loaded_graphic == "Wereshi"
            @speed = (Difficulty.get == Difficulty::DOOM ? 3 : 2)
            @score = 2000
            @strength = 1
            @defense = 0
            @hp = 1
            @jump_speed = -15
            @hunting = false
            @abyss_turn = true
            @border_turn = true
            @border_jump_delay = nil
            @abyss_jump_delay = nil
        end
    end
    
end
