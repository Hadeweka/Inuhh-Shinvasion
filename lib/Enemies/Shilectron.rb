class Shilectron < Enemy
    
    def activation
        @strength = (Difficulty.get > Difficulty::NORMAL ? (Difficulty.get == Difficulty::DOOM ? 3 : 2) : 1)
        @gravity = false
        @hp = 3
        @strength = 3
        @speed = 3
        @defense = 0
        @score = 8000
        @through = true
        @centrum = nil
        @init_centrum = [x, y]
        @radius = 100
        if @param then
            @radius = 50*@param
        end
        @world = 3
        @waterproof = true
        @va = (@dir == :right ? 1 : -1)*0.02*Math::PI
        @angle = 0
        @range = 100000
        @no_harm_time = 0
        load_graphic("Shilectron")
        @description = "A Shi bound to a block or entity.
        It orbits around it in fixed circles.
        Found in Shi buildings and dark places."
    end
    
    def set_no_harm_time(value)
        @no_harm_time = value
        @dangerous = false
        @shading = 0x88ffffff
    end
    
    def bind(enemy, radius, angle, momentum, hp, strength)
        @centrum = enemy
        @radius = radius
        @angle = angle
        @va = momentum/@radius.to_f**2
        @hp = hp
        @strength = strength
        @score = 1000
    end
    
    def turn_to(dir)
        @va = (dir == :left ? -@va.abs : @va.abs)
    end
    
    def update(cam_x, cam_y)
        @tics += 1
        @invul -= 1 if @invul > 0
        @inuhh = @window.inuhh
        return nil unless check_range(cam_x, cam_y)
        if @centrum then
            @x = @centrum.x + @radius*Math::cos(@angle)
            @y = @centrum.y + @ysize - @centrum.ysize + @radius*Math::sin(@angle)
            @angle += @va
            @cur_image = @standing
        else
            @x = @init_centrum[0] + @radius*Math::cos(@angle)
            @y = @init_centrum[1] + @radius*Math::sin(@angle)
            @angle += @va
            @cur_image = @standing
        end
        @damage_counter -= 1
        if @no_harm_time > 0 then
            @no_harm_time -= 1
        else
            @dangerous = true
            @shading = 0xffffffff
        end
    end
    
end
