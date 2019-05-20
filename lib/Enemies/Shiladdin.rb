class Shiladdin < Enemy
    
    def activation
        @strength = 8
        @defense = 0
        @hp = 18
        @score = 20000
        @drop = Objects::Magic_Lamp
        @speed = 2
        @world = 6
        @hunting = true
        @border_turn = false
        @abyss_turn = false
        @border_jump_delay = 1
        @abyss_jump_delay = 1
        if !EDITOR && !SHIPEDIA then
            @shinny = @window.spawn_enemy(Enemies::Shinny, @x, @y - @ysize - 100, @dir)
            @shinny.bind(self)
        end
        @wondering = false
        load_graphic("Shiladdin")
        @description = "T"
    end
    
    def custom_mechanics
        if @wondering then
            @dir = :right if @wondering == 100 || @wondering == 50
            @dir = :left if @wondering == 75 || @wondering == 25
            @wondering -= 1
            if @wondering <= 0 then
                @wondering = false
                @dir_set = false
            end
        end
        if @shinny && @shinny.hp <= 0 then
            @shinny = nil
            @wondering = 100
            @hunting = false
            @speed = 0
            @moving = false
            @dir_set = true
        end
    end
    
end
