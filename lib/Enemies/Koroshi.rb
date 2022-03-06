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
        @original_ysize = 200
        @range = 2000
        @reduction = 1
        @mindamage = 2
        @spike_strength = @strength
        @minsdamage = @mindamage
        @troops = {}
        @jump_speed = -30
        @jump_image = false
        @crouching = false
        @crouch_jumping = false
        @has_jumped = false
        @squeeze_level = 1.0
        @spit_cooldown = 0
        @drop = Objects::Key
        load_graphic("Koroshi")
        @description = "Probably the biggest Shi alive. Due to its enormous size
        it can crush nearly all living beings to deaths beings.
        It has a bad defense, so jumping on its head will damage it.
        Spits out other Shi and might jump or even run fast if provoked.
        Found in the depths of the Dominwood Forest."
    end

    def try_to_crouch
        if !@crouching && !@crouch_jumping
            @crouching = true
        end
    end

    def draw
        return if @invisible && !EDITOR
        # Flip vertically when facing to the left.
        if @dir == :left then
            offs_x = -@xsize
            factor = 1.0
        else
            offs_x = @xsize
            factor = -1.0
        end
        if EDITOR then
            @cur_image = @standing if !@moving && !@dir_set
            @cur_image.draw(@x + offs_x, @y - @ysize*2 + 1, ZOrder::Enemies, factor, 1.0, @shading)
        else
            distance = 200.0
            factor = 1.0 if !@moving && !@dir_set
            zxsize = @xsize*1.0/(1.0 + @z/distance)
            zysize = @ysize*1.0/(1.0 + @z/distance)
            zord = (@z < 0 ? ZOrder::Foreground : ZOrder::Enemies)
            @cur_image.draw(@x - factor*zxsize, @y - zysize*2 + 1 + zysize-@ysize, zord, factor*zxsize/@xsize, zysize/@ysize*@squeeze_level, @shading)
        end
    end

    def spit_out(e_class, max_number, with_knockback = true)
        @troops[e_class] = [] if !@troops[e_class]
        return if @troops[e_class].size >= max_number
        new_x = @x + (@dir == :left ? -@xsize : @xsize) * 0.8
        new_y = @y - @ysize * 0.25
        if !@map.solid?(new_x, new_y)
            en = @window.spawn_enemy(e_class, new_x, new_y, @dir)
            en.extend_range
            en.force_knockback((@dir == :left ? -10 : 10)) if with_knockback
            @troops[e_class].push(en)
            @spit_cooldown = 100
        end
    end

    def at_death
        @troops.each_value do |e_class_values|
            @window.play_sound("detonation", 0.6, 0.5)
            e_class_values.each do |e|
                e.damage(10)
            end
        end
    end

    def custom_mechanics
        if @has_jumped && !would_fit(0, 1)
            @has_jumped = false
            @window.play_sound("detonation", 0.5, 0.3)
            @inuhh.knockback((@inuhh.x < @x ? -20 : 20)) unless @inuhh.vy != 0
            @inuhh.try_to_jump
        end

        if @hp <= @maxhp * 0.5 || Difficulty.get > Difficulty::HARD
            if @inuhh.y <= @y && @inuhh.y > @y - @ysize && (@inuhh.x > @x - 250 && @inuhh.x < @x && @dir == :left) || (@inuhh.x < @x + 250 && @inuhh.x > @x && @dir == :right)
                @speed = (Difficulty.get > Difficulty::NORMAL ? 8 : 6)
            elsif @inuhh.y <= @y && @inuhh.y > @y - @ysize && (@inuhh.x > @x - 500 && @inuhh.x < @x && @dir == :left) || (@inuhh.x < @x + 500 && @inuhh.x > @x && @dir == :right)
                @speed = (Difficulty.get > Difficulty::NORMAL ? 4 : 3)
            else
                @speed = 2
            end
        else
            @speed = 2
        end

        if @crouching
            if @squeeze_level <= 0.5
                try_to_jump
                @has_jumped = true
                @crouch_jumping = true
                @crouching = false
            else
                @squeeze_level *= 0.99
                @ysize = @squeeze_level * @original_ysize
            end
        elsif @crouch_jumping
            @squeeze_level *= 1.1
            if @squeeze_level >= 1.0
                @ysize = @squeeze_level * @original_ysize
                @squeeze_level = 1.0
                @crouch_jumping = false
            end
        else
            @squeeze_level = 1.0
            @ysize = @original_ysize
        end

        @spit_cooldown -= 1 if @spit_cooldown > 0

        @spike = (@vy < 0.0)

        if @vy == 0 && @spit_cooldown == 0
            if rand(100) == 0
                spit_out(Enemies::Daishi, 10)
            elsif rand(200) == 0
                spit_out(Enemies::Shitake, 10)
            elsif rand(300) == 0 && Difficulty.get > Difficulty::EASY
                spit_out(Enemies::Yasushi, 10, false)
            elsif rand(500) == 0 && Difficulty.get > Difficulty::HARD
                spit_out(Enemies::Takashi, 2, false)
            elsif rand(500) == 0 && @hp <= @maxhp * 0.4 && Difficulty.get > Difficulty::EASY
                spit_out(Enemies::Enershi, 2, false)
            elsif rand(600) == 0 && Difficulty.get > Difficulty::EASY
                spit_out(Enemies::Shiparrow, 10)
            elsif rand(1000) == 0 && Difficulty.get > Difficulty::HARD
                spit_out(Enemies::Shihog, 5, false)
            end
        end

        if rand((Difficulty.get > Difficulty::NORMAL ? 1000 : 2000)) == 0 && @hp < @maxhp
            try_to_crouch
        end

        @troops.each_value do |e_class_values|
            e_class_values.each do |e|
                if !e.living then
                    e_class_values.delete(e)
                end
            end
        end
    end

    def damage(value)
        super(value)
        try_to_crouch
    end
    
end
