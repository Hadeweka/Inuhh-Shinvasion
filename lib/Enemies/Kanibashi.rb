class Kanibashi < Enemy
    
    def activation
        @hp = 15
        @maxhp = @hp
        @score = 16000
        @strength = 3
        @mindamage = (Difficulty.get > Difficulty::NORMAL ? 2 : 1)
        @speed = 3
        @xsize = 50
        @ysize = 50
        @range = 600
        @world = 5
        @nearest = nil
        @nom_delay = 0
        load_graphic("Kanibashi")
        @description = "Rude and big Shi with low strength, high health
        and a dangerous hunger. Will devour everything
        living to replenish its health. EVERYTHING
        Therefore it is one of the best hunting Shi.
        Can be tricked into eating Shi with spikes.
        Lives on the Shi Trail."
    end
    
    def move_mechanics
        if @nearest then
            if @hunt_delay >= @hunt_max_delay then
                if @dodge then
                    if @nearest.x - @x < -100*@dodge_range then
                        @dir = :left if @vy == 0 || @air_control || @waterproof
                    elsif @nearest.x - @x > 100*@dodge_range
                        @dir = :right if @vy == 0 || @air_control || @waterproof
                    end
                else
                    @dir = (@nearest.x < @x ? :left : :right)
                end
                @hunt_delay = 0
            end
            @hunt_delay += 1
        end
        super()
    end
    
    def custom_mechanics
        @nearest = nil if @nearest && @nearest != @inuhh && !@nearest.living
        @window.enemies.each do |e|
            next if e == self
            if @hp < @maxhp && (!@nearest || (e.x-@x)**2+(e.y-@y)**2 < (@nearest.x-@x)**2+(@nearest.y-@y)**2) then
                @nearest = e
            end
        end
        if @hp < @maxhp && (!@nearest || (@inuhh.x-@x)**2+(@inuhh.y-@y)**2 < (@nearest.x-@x)**2+(@nearest.y-@y)**2) then
            @nearest = @inuhh
        end
        if @nom_delay <= 0 && @nearest && Collider.elliptic(@xsize, @ysize, @nearest.xsize, @nearest.ysize, @x-@nearest.x, @y-@nearest.y) then
            @nearest.damage(1) if @nearest != @inuhh
            if @nearest != @inuhh && @nearest.spike then
                @window.messages.push([@nearest.spike_strength.to_s, @x, @y+@ysize, 100, true, 2.0, 2.0, 0xff00ff00])
                damage(@nearest.spike_strength)
            end
            hpdiff = 1
            hpdiff += [@strength-@inuhh.stats[Stats::Defense]-1, 0].max if @nearest == @inuhh
            hpdiff -= (@hp+hpdiff-@maxhp) if @hp+hpdiff > @maxhp
            @hp += hpdiff
            @nom_delay = 50
            hpdiff = 0 if @inuhh.invincible != 0 || @inuhh.inv_inv != 0
            @window.messages.push(["+ #{hpdiff}", @x, @y+@ysize, 100, true, 2.0, 2.0, 0xff8800ff]) if hpdiff > 0
        end
        @nearest = nil if @hp == @maxhp
        try_to_jump if @nearest && @nearest.y < @y-2*@ysize && rand(10) == 0
        @speed = rand(10) if @nearest == @inuhh && rand(20) == 0
        @speed = 3 if !@nearest
        @border_turn = !@nearest
        @border_jump_delay = (@nearest ? 10 : nil)
        @abyss_jump_delay = (@nearest ? 10 : nil)
        @abyss_turn = !@nearest
        @nom_delay -= 1
    end
    
end
