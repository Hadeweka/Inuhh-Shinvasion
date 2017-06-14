class Grasshi < Enemy
    
    def activation
        @hp = 1
        @score = 10000
        @waterproof = true
        @speed = 2
        @strength = 3
        @defense = 1
        @spike = true
        @spike_strength = 3
        @minsdamage = 1
        @world = 4
        @hunting = true
        @abyss_turn = false
        @border_turn = true
        @random_jump_delay = (Difficulty.get > Difficulty::EASY ? 1000 : nil)
        @border_jump_delay = 2
        @projectile = true
        @projectile_reload = 40
        @projectile_damage = 3
        @projectile_offset = [0.0, -@ysize+2.5]
        @projectile_mechanics = [5.0, 0.0, 0.0, 0.0]
        load_graphic("Grasshi")
        @description = "Brutal variant of water-riding Shi. It can shoot, hunt and
        has got some serious spikes. Also gets ridiculous speeds on water.
        Nevertheless it only appears rarely, for example in ice caves."
    end
    
    def would_fit(offs_x, offs_y)
        expr = super(offs_x, offs_y)
        0.upto((@ysize/25).floor) do |t|
            (-@xsize/50+1).floor.upto((@xsize/50).floor) do |u|
                edge_y = t == 0 ? 0 : 1
                edge_x = 0
                expr &&= !@map.water(@x + offs_x + 25 - (@xsize>25 ? 25 : 0) + u*50 - edge_x, @y + offs_y - 50*(t) + edge_y)
                expr &&= !@map.water(@x + offs_x - 24 - (@xsize>25 ? 25 : 0) + u*50 - edge_x, @y + offs_y - 50*(t) + edge_y)
            end
        end
        return expr
    end
    
    def move_mechanics
        super
        @speed = 10 if @map.water(@x - @xsize + 1, @y + 1) || @map.water(@x + @xsize - 1, @y + 1)
        @speed = 2 if @map.solid?(@x - @xsize + 1, @y + 1) || @map.solid?(@x + @xsize - 1, @y + 1)
    end
    
    def try_to_jump
        if @map.solid?(@x - @xsize + 1, @y + 1) || @map.solid?(@x + @xsize - 1, @y + 1) then
            @vy = -15
            @jumping = true
            @window.play_sound("jump") if !@air_control && would_fit(0, -1) && (@inuhh.x - @x).abs <= 320 && (@inuhh.y - @y).abs < 240
        elsif  @map.water(@x - @xsize + 1, @y + 1) || @map.water(@x + @xsize - 1, @y + 1) then
            @vy = -20
            @jumping = true
            @window.play_sound("jump") if !@air_control && would_fit(0, -1) && (@inuhh.x - @x).abs <= 320 && (@inuhh.y - @y).abs < 240
        end
    end
    
end
