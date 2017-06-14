class Koroshi < Enemy
    
    def activation
        @hp = (Difficulty.get == Difficulty::EASY ? 10 : (Difficulty.get < Difficulty::HARD ? 15 : (Difficulty.get < Difficulty::DOOM ? 20 : 25)))
        @strength = (Difficulty.get > Difficulty::NORMAL ? 4 : 3)
        @maxhp = @hp
        @boss = true
        @score = 48000
        @world = 2
        @xsize = 200
        @ysize = 200
        @range = 2000
        @reduction = 1
        @mindamage = 2
        @jump_image = false
        @drop = Objects::Wing
        @random_jump_delay = (Difficulty.get > Difficulty::NORMAL ? (Difficulty.get > Difficulty::HARD ? 500 : 1000) : nil)
        load_graphic("Koroshi")
        @description = "Propably the biggest Shi alive. Because of its enormous size
        it can crush nearly every living being to death beings.
        Still it has no defense, so jumping on its head will damage it.
        Because of this weakness it is guarded very well.
        Found in the depths of the Dominwood Forest."
    end
    
    def try_to_jump
        if @map.solid?(@x - @xsize + 1, @y + 1) || @map.solid?(@x + @xsize - 1, @y + 1) then
            @vy = (Difficulty.get > Difficulty::HARD ? -20 : -15)
            @jumping = true
            @window.play_sound("jump") if !@air_control && would_fit(0, -1) && (@inuhh.x - @x).abs <= 320 && (@inuhh.y - @y).abs < 240
        end
    end
    
end
