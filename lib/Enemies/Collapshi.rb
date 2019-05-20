class Collapshi < Enemy
    
    def activation
        @score = 13000
        @speed = 0
        @hp = 8
        @world = 6
        @maxhp = @hp
        @strength = 5
        @defense = 2
        @range = 200
        @moving = false
        @gravity = false
        @abyss_turn = false
        @dir_set = true
        @no_knockback = true
        @collapsed = false
        @param = 0 if !@param
        @tile = @param % 2	# 0 = Tree, 1 = Leaf
        @tree = (@param/2).to_i
        @invisible = true if SHIPEDIA
        if !EDITOR && !SHIPEDIA && !@window.triggers[Trigger_ID::Shiesaw + @tree] then
            @window.triggers[Trigger_ID::Collapshi + @tree] = 0
        end
        load_graphic("Collapshi")
        @speed = (Difficulty.get > Difficulty::EASY ? 3 : 2) if SHIPEDIA
        @gravity = true if SHIPEDIA
        @description = "T"
    end
    
    def draw
        if SHIPEDIA || EDITOR || @hp < @maxhp then
            super()
        elsif @collapsed then
            @cur_image = (@tile == 0 ? @map.tileset[Tiles::Wood] : @map.tileset[Tiles::Tree])
            @cur_image.draw(@x - @xsize - 5, @y - @ysize*2 - 5, ZOrder::Enemies)
        else
            @cur_image = (@tile == 0 ? @map.tileset[Tiles::Wood] : @map.tileset[Tiles::Tree])
            @cur_image.draw(@x - 5 - @x%50, @y - @ysize*2 + 50 - 5 - @y%50, ZOrder::Tiles)
        end
    end
    
    def custom_mechanics
        if (@hp < @maxhp || @window.triggers[Trigger_ID::Collapshi + @tree] == 1) && !@moving then
            @speed = (Difficulty.get > Difficulty::EASY ? 3 : 2)
            @moving = true
            @gravity = true
            @collapsed = true
            @window.triggers[Trigger_ID::Collapshi + @tree] = 1
        end
    end
    
    def damage(value)
        super(value)
        @window.triggers[Trigger_ID::Collapshi + @tree] = 1
        @collapsed = true
    end
    
    def at_collision
        @window.triggers[Trigger_ID::Collapshi + @tree] = 1
        @collapsed = true
    end
    
end
