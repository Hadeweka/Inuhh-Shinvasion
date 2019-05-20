class Shicore < Enemy
    
    attr_reader :loyality
    
    def activation
        @speed = 0
        @world = 6
        @score = 0
        @hp = 5
        @range = 100000
        @loyality = (@param == 1 ? 1 : 0)	# 1 = Enemy, 0 = Ally
        @strength = 0
        @defense = 1000
        @no_knockback = true
        @moving = false
        @dir_set = true
        @destiny = true
        @gravity = false
        @big_shi = nil
        @dangerous = false
        @transparent = true
        @knockback = 10
        load_graphic("Shicore")
        @description = "T"
    end
    
    def at_shot(projectile)
        if projectile.type == Projectiles::Ball then
            dv = 1
            damage(dv)
            if @big_shi && @loyality == 1 then
                @window.messages.push([dv, @big_shi.x-@big_shi.xsize+10, @big_shi.y-@big_shi.ysize-30, 20, true, 2.0+(dv-1)/30.0, 2.0+(dv-1)/30.0, 0xff00ff00]) if @big_shi
                @big_shi.damage(1) if @big_shi
            end
            @window.messages.push([dv, @x-@xsize+10, @y-@ysize-30, 20, true, 2.0+(dv-1)/30.0, 2.0+(dv-1)/30.0, 0xff00ff00])
            @window.gems.push(Object_Datas::C_Index[Objects::Ball].new(@window.valimgs[Objects::Ball], 100*50/2, @y + 100)) if @hp > 0
        end
        @shading = [0xff000000, 0xff333333, 0xff666666, 0xff999999, 0xffcccccc, 0xffffffff][@hp]
        if @hp == 0 && @loyality == 0 then
            @big_shi.go_berserk
        end
        projectile.destroy
    end
    
    def custom_mechanics
        if !@big_shi then
            @window.enemies.each do |e|
                next unless e.is_a?(Big_Shi)
                @big_shi = e
                break
            end
        end
    end
    
end
