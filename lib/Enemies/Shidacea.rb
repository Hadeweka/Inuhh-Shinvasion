class Shidacea < Enemy
    
    def activation
        @speed = 0
        @hp = 14
        @reduction = 1
        @strength = (Difficulty.get > Difficulty::EASY ? 7 : 5)
        @world = 5
        @dir_set = true
        @hunting = true
        @dodge = false
        @moving = false
        @waterproof = true
        @score = 15000
        @ysize = 100 if SHIPEDIA
        @y -= 150
        load_graphic("Shidacea")
        @description = "If a Hyashi gets watered enough it will
        grow to this beauty. Only the upper part
        is harmful. Also it can't move anymore.
        Would make a nice decoration.
        Can't be found naturally."
    end
    
    def load_graphic(name)
        @standing, @walk1, @walk2, @jump, @mud = *Image.load_tiles("media/enemies/#{name}.png", 2*@xsize, 200, tileable: true)
        @cur_image = @walk1
        @loaded_graphic = name
    end
    
    def custom_mechanics
        @gravity = would_fit(0, 150)
        @vy = 0 if !@gravity
        @vy = 1 if @gravity
    end
    
end
