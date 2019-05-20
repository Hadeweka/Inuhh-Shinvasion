class Polishi < Enemy
    
    def activation
        @world = 6
        @strength = 5
        @defense = 5
        @hp = 17
        @reduction = 1
        @score = 21000
        @nearest = nil
        @speed = 4
        @punch_delay = 0
        load_graphic("Polishi")
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
            next unless e.criminal
            if !@nearest || (e.x-@x)**2+(e.y-@y)**2 < (@nearest.x-@x)**2+(@nearest.y-@y)**2 then
                @nearest = e
            end
        end
        if !@nearest || (@inuhh.x-@x)**2+(@inuhh.y-@y)**2 < (@nearest.x-@x)**2+(@nearest.y-@y)**2 then
            @nearest = @inuhh
        end
        if @punch_delay <= 0 && @nearest && Collider.elliptic(@xsize, @ysize, @nearest.xsize, @nearest.ysize, @x-@nearest.x, @y-@nearest.y) then
            @nearest.damage(1) if @nearest != @inuhh
            if @nearest != @inuhh && @nearest.spike then
                @window.messages.push([@nearest.spike_strength.to_s, @x, @y+@ysize, 100, true, 2.0, 2.0, 0xff00ff00])
                damage(@nearest.spike_strength)
            end
            hpdiff = 1
            hpdiff += [@strength-@inuhh.stats[Stats::Defense]-1, 0].max if @nearest == @inuhh
            hpdiff -= (@hp+hpdiff-@maxhp) if @hp+hpdiff > @maxhp
            @hp += hpdiff
            @punch_delay = 30
            hpdiff = 0 if @inuhh.invincible != 0 || @inuhh.inv_inv != 0
            @window.messages.push(["+ #{hpdiff}", @x, @y+@ysize, 100, true, 2.0, 2.0, 0xff8800ff]) if hpdiff > 0
        end
        try_to_jump if @nearest && @nearest.y < @y-2*@ysize && rand(10) == 0
        @border_turn = !@nearest
        @border_jump_delay = (@nearest ? 10 : nil)
        @abyss_jump_delay = (@nearest ? 10 : nil)
        @abyss_turn = !@nearest
        @punch_delay -= 1
    end
    
end
